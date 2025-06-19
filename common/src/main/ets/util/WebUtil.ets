/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { uri } from '@kit.ArkTS';
import { BuilderNode, FrameNode, NodeController, window } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { ModuleNameEnum, ScrollDirectionEnum } from '../constant/CommonEnums';
import Logger from './Logger';
import { NetworkUtil } from './NetworkUtil';
import { ConfigMapKey, ResourceUtil } from './ResourceUtil';

const TAG: string = '[WebUtil]';

const webNodeMap: Map<string, WebNodeController> = new Map();
const webControllerMap: Map<string, WebviewController | undefined> = new Map();
const eventEmitterMap: Map<string, Function> = new Map();
const sheetEventMap: Map<string, Function> = new Map();
const pageEventMap: Map<string, Function> = new Map();
const nodeRequiredMap: Map<string, boolean> = new Map(); // Check whether web node is required again.
const webLoadedMap: Map<string, boolean> = new Map();
let currentOffset: number = 0;
let context: UIContext;

const componentCodeHtml: string = `/codePreview/index.html`;

interface WebBuilderParam {
  webUrl: string;
  webController: WebviewController;
  nestedScroll: NestedScrollOptions;
  nativeActionData: NativeActionData;
  module?: ModuleNameEnum;
  onlyWhiteMode?: boolean;
  verticalScrollBarAccess?: boolean;
}

@Builder
function webBuilder(param: WebBuilderParam) {
  Web({ src: param.webUrl, controller: param.webController })
    .zoomAccess(false)
    .fileAccess(true)
    .imageAccess(true)
    .mixedMode(MixedMode.None)
    .verticalScrollBarAccess(param.verticalScrollBarAccess)
    .horizontalScrollBarAccess(false)
    .cacheMode(CacheMode.Default)
    .domStorageAccess(true)
    .javaScriptAccess(true)
    .javaScriptProxy(param.module === ModuleNameEnum.ARTICLE_DETAIL ? {
      object: param.nativeActionData,
      name: 'nativeActionData',
      methodList: ['webSheet', 'jumpPage'],
      controller: param.webController,
      permission: javascriptProxyPermission,
    } : undefined)
    .geolocationAccess(false)
    .backgroundColor(Color.Transparent)
    .nestedScroll(param.nestedScroll)
    .darkMode(param.onlyWhiteMode ? WebDarkMode.Off : WebDarkMode.Auto)
    .forceDarkAccess(true)
    .allowDrop(null)
    .onPageBegin(() => {
      param.webController.onActive();
      Logger.debug(TAG, `onPageBegin with url: ${param.webUrl}`);
    })
    .onPageEnd(() => {
      AppStorage.setOrCreate('webIsLoading', false);
      WebUtil.setTrustList(param.webUrl);
      Logger.debug(TAG, `onPageEnd with url: ${param.webUrl}`);
    })
    .onLoadIntercept((event: OnLoadInterceptEvent) => {
      const tempUrl = event.data.getRequestUrl();
      return WebUtil.checkUrl(tempUrl);
    })
    .onSslErrorEventReceive((event) => {
      Logger.error(TAG, `SSL checked failed, error: ${event.error.toString()}`);
      event.handler.handleCancel();
    })
    .onScroll((event) => {
      if (param.module && event.yOffset) {
        const eventEmitter = eventEmitterMap.get(param.module);
        const scrollOffset: number = event.yOffset - currentOffset;
        currentOffset = event.yOffset;
        if (scrollOffset > 0) {
          eventEmitter && eventEmitter(ScrollDirectionEnum.DOWN, currentOffset);
        } else if (scrollOffset < 0) {
          eventEmitter && eventEmitter(ScrollDirectionEnum.UP, currentOffset);
        }
      }
    })
    .onControllerAttached(() => {
      try {
        param.webController.onActive();
        const userAgent = `${param.webController.getUserAgent()} Mobile`;
        param.webController.setCustomUserAgent(userAgent);
        // Setting the local file path that allows cross-domain access.
        param.webController.setPathAllowingUniversalAccess([getContext().resourceDir]);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `Web User-Agent setting error: ${err.code}, ${err.message}.`);
      }
    })
    .width('100%')
    .height('100%')
}

export class NativeActionData {
  public webSheet: (src: string, type: number) => void;
  public jumpPage: (type: string, id: number, currentIndex?: number, componentName?: string) => void;

  constructor(url: string) {
    this.webSheet = (src: string, type: number) => {
      const sheetEvent = sheetEventMap.get(url);
      if (sheetEvent !== undefined) {
        sheetEvent(src, type);
      }
    };

    this.jumpPage = (type: string, id: number, currentIndex?: number, componentName?: string) => {
      const sheetEvent = pageEventMap.get(url);
      if (sheetEvent !== undefined) {
        sheetEvent(type, id, currentIndex, componentName);
      }
    }
  }
}

export class WebUtil {
  public static readonly ARTICLE_WHITE_METHODS: string[] = ['checkPreview()', 'closePreview()'];

  static addNode(url: string) {
    webNodeMap.get(url)?.add();
  }

  public static initialize(windowStage: window.WindowStage) {
    try {
      context = windowStage.getMainWindowSync().getUIContext();
      webNodeMap.clear();
      webControllerMap.clear();
      webview.WebviewController.initializeWebEngine();
      WebUtil.createWebNode(WebUtil.getComponentCodeUrl(), context, undefined, ModuleNameEnum.CODE_PREVIEW, true,
        false);
    } catch (err) {
      Logger.error(TAG, `Initialize failed. Cause: ${err.code} ${err.message}`);
    }
  }

  public static removeNode(url: string) {
    if (nodeRequiredMap.has(url)) {
      Logger.info(TAG, `Web Node is Required again, should not dispose: ${url}`);
      nodeRequiredMap.delete(url);
      return;
    }
    const webNode = WebUtil.getWebNode(url);
    webNode?.disposeNode();
    webLoadedMap.delete(url);
    webNodeMap.delete(url);
    webControllerMap.delete(url);
    Logger.debug(TAG, `removeNode with url: ${url}`);
  }

  public static checkWebLoaded(url: string): boolean {
    const loaded: boolean = !!webLoadedMap.get(url);
    if (!loaded && NetworkUtil.hasDefaultNet()) {
      const webController = WebUtil.getWebController(url);
      AppStorage.setOrCreate('webIsLoading', true);
      webLoadedMap.set(url, true);
      webController?.refresh();
      return true;
    }
    return loaded;
  }

  public static createWebNode(webUrl: string, uiContext?: UIContext, nestedScrollMode?: NestedScrollMode,
    module?: ModuleNameEnum, onlyWhiteMode?: boolean, verticalScrollBarAccess?: boolean) {
    if (webNodeMap.has(webUrl)) {
      nodeRequiredMap.set(webUrl, true);
      Logger.debug(TAG, `Has web node with url: ${webUrl}, should not create web node.`);
      return;
    }
    if (!context && uiContext) {
      context = uiContext;
    }
    Logger.debug(TAG, `initWebNode with url: ${webUrl}`);
    const webNode = new WebNodeController();
    const webController = new webview.WebviewController();
    const webBuilderParam: WebBuilderParam = {
      webUrl: webUrl,
      webController: webController,
      nestedScroll:
      {
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      },
      module: module,
      onlyWhiteMode,
      nativeActionData: new NativeActionData(webUrl),
      verticalScrollBarAccess: verticalScrollBarAccess || false,
    };
    if (nestedScrollMode !== undefined) {
      webBuilderParam.nestedScroll = {
        scrollForward: nestedScrollMode,
        scrollBackward: nestedScrollMode,
      };
    }
    webNode.initWebNode(context, webBuilderParam);
    webLoadedMap.set(webUrl, NetworkUtil.hasDefaultNet());
    webControllerMap.set(webUrl, webController);
    webNodeMap.set(webUrl, webNode);
  }

  public static updateWebNode(webUrl: string, nestedScrollMode?: NestedScrollMode, module?: ModuleNameEnum,
    onlyWhiteMode?: boolean, verticalScrollBarAccess?: boolean) {
    const webController = webControllerMap.get(webUrl)!;
    const webBuilderParam: WebBuilderParam = {
      webUrl: webUrl,
      webController: webController,
      nestedScroll:
      {
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      },
      module: module,
      onlyWhiteMode,
      nativeActionData: new NativeActionData(webUrl),
      verticalScrollBarAccess: verticalScrollBarAccess || false,
    };
    if (nestedScrollMode !== undefined) {
      webBuilderParam.nestedScroll = {
        scrollForward: nestedScrollMode,
        scrollBackward: nestedScrollMode,
      };
    }
    const nodeController: WebNodeController | undefined = webNodeMap.get(webUrl);
    if (nodeController) {
      nodeController.updateWebNode(webBuilderParam);
    }
  }

  public static getWebNode(webUrl: string): WebNodeController | undefined {
    return webNodeMap.get(webUrl);
  }

  public static getWebController(webUrl: string): webview.WebviewController | undefined {
    return webControllerMap.get(webUrl);
  }

  public static setWebController(webUrl: string, webViewController: webview.WebviewController): void {
    webControllerMap.set(webUrl, webViewController);
  }

  public static setTrustList(webUrl: string): void {
    const webController: webview.WebviewController = webControllerMap.get(webUrl)!;
    try {
      const whitelist: string = ResourceUtil.getRawFileStringByKey(getContext(), ConfigMapKey.WHITELIST);
      webController?.setUrlTrustList(whitelist);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Web User-Agent setting error: ${err.code}, ${err.message}.`);
    }
  }

  public static checkUrl(url: string): boolean {
    const tempUri: uri.URI = new uri.URI(url);
    const res: uri.URI = tempUri.normalize();
    Logger.debug(TAG, `Web request url : ${res.toString()}`);
    return false;
  }

  public static registerEmitter(module: ModuleNameEnum, callback: Function) {
    eventEmitterMap.set(module, callback);
  }

  public static setWebSheetAction(url: string, callback: Function) {
    sheetEventMap.set(url, callback);
  }

  public static setJumpPageAction(url: string, callback: Function) {
    pageEventMap.set(url, callback);
  }

  public static getComponentCodeUrl() {
    return getContext().resourceDir + componentCodeHtml;
  }
}

export class WebNodeController extends NodeController {
  private rootNode: BuilderNode<WebBuilderParam[]> | null = null;
  private isRemove: boolean = false;

  makeNode(): FrameNode | null {
    if (this.isRemove === true) {
      return null;
    }
    if (this.rootNode) {
      return this.rootNode.getFrameNode();
    }
    return null;
  }

  disposeNode() {
    this.rootNode?.dispose();
  }

  remove() {
    this.isRemove = true;
    this.rebuild();
    this.isRemove = false;
  }

  add() {
    this.isRemove = false;
    this.rebuild();
  }

  initWebNode(uiContext: UIContext, webBuilderParam: WebBuilderParam) {
    if (!this.rootNode) {
      this.rootNode = new BuilderNode(uiContext);
      this.rootNode.dispose();
      this.rootNode.build(wrapBuilder<WebBuilderParam[]>(webBuilder), webBuilderParam);
    }
  }

  updateWebNode(webBuilderParam: WebBuilderParam) {
    if (this.rootNode) {
      this.rootNode.update(webBuilderParam);
    }
  }
}

export const javascriptProxyPermission = `{
    "javascriptProxyPermission": {
      "urlPermissionList": [
        {
          "scheme": "resource",
          "host": "resfile",
          "port": "",
          "path": ""
        }
      ],
      "methodList": [
        {
          "methodName": "toHref",
          "urlPermissionList": [
            {
              "scheme": "resource",
              "host": "resfile",
              "port": "",
              "path": ""
            }
          ]
        },
        {
          "methodName": "jumpSampleDetail",
          "urlPermissionList": [
            {
              "scheme": "resource",
              "host": "resfile",
              "port": "",
              "path": ""
            }
          ]
        },
        {
          "methodName": "jumpComponentDetail",
          "urlPermissionList": [
            {
              "scheme": "resource",
              "host": "resfile",
              "port": "",
              "path": ""
            }
          ]
        }
      ]
    }
  }`;