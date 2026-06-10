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

import { common, Want } from '@kit.AbilityKit';
import { uri } from '@kit.ArkTS';
import { BuilderNode, FrameNode, NodeController, UIContext, window } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { ModuleNameEnum, ScrollDirectionEnum, StorageKey } from '../constant/CommonEnums';
import Logger from './Logger';
import { NetworkUtil } from './NetworkUtil';
import { ConfigMapKey, ResourceUtil } from './ResourceUtil';
import { ProcessUtil } from './ProcessUtil';

const TAG: string = '[WebUtil]';

const webNodeMap: Map<string, WebNodeController> = new Map();
const webControllerMap: Map<string, WebviewController | undefined> = new Map();
const eventEmitterMap: Map<string, Function> = new Map();
const sheetEventMap: Map<string, Function> = new Map();
const pageEventMap: Map<string, Function> = new Map();
const previewEventMap: Map<string, Function> = new Map();
const nodeRequiredMap: Map<string, boolean> = new Map(); // Check whether web node is required again.
const webLoadedMap: Map<string, boolean> = new Map();
const webMockScrollerMap: Map<string, Scroller> = new Map();
let currentOffset: number = 0;

const componentCodeHtml: string = `/codePreview/index.html`;

interface WebBuilderParam {
  webUrl: string;
  webController: WebviewController;
  nestedScroll: NestedScrollOptions;
  nativeActionData: NativeActionData;
  webMockScroller?: Scroller;
  module?: ModuleNameEnum;
  onlyWhiteMode?: boolean;
  verticalScrollBarAccess?: boolean;
}

@Builder
function webBuilder(param: WebBuilderParam) {
  Stack() {
    Scroll(param.webMockScroller).zIndex(-1)
    Scroll() {
      Web({ src: param.webUrl, controller: param.webController })
        .zoomAccess(false)
        .fileAccess(false)
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
          methodList: ['webSheet', 'jumpPage', 'imagePreviewChanged'],
          controller: param.webController,
          permission: WebUtil.getJsPermission(),
        } : undefined)
        .onLoadFinished(() => {
          if (AppStorage.get<string>('caller') === 'com.huawei.hmos.aidispatchservice') {
            setTimeout(() => {
              AppStorage.setOrCreate(StorageKey.WEB_LOADING, false);
            }, 700)
            AppStorage.delete('caller');
          } else {
            AppStorage.setOrCreate(StorageKey.WEB_LOADING, false);
          }
        })
        .geolocationAccess(false)
        .backgroundColor(Color.Transparent)
        .nestedScroll(param.nestedScroll)
        .darkMode(param.onlyWhiteMode ? WebDarkMode.Off : WebDarkMode.Auto)
        .forceDarkAccess(true)
        .allowDrop(null)
        .onPageBegin(() => {
          try {
            param.webController.onActive();
            Logger.debug(TAG, `onPageBegin with url: ${param.webUrl}`);
          } catch (error) {
            Logger.error(TAG, `onPageBegin with url: ${param.webUrl} failed. error ${error.message}`);
          }
        })
        .onPageEnd(() => {
          Logger.debug(TAG, `onPageEnd with url: ${param.webUrl}`);
        })
        .onLoadIntercept((event: OnLoadInterceptEvent) => {
          return WebUtil.handleLoadIntercept(event);
        })
        .onSslErrorEventReceive((event) => {
          Logger.error(TAG, `SSL checked failed, error: ${event.error.toString()}`);
          event.handler.handleCancel();
        })
        .onScroll((event: OnScrollEvent) => {
          param.webMockScroller?.scrollTo({ xOffset: event.xOffset, yOffset: event.yOffset });
          if (param.module) {
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
          const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
          try {
            param.webController.onActive();
            const userAgent = `${param.webController.getUserAgent()} Mobile (Phone; OpenHarmony)`;
            param.webController.setCustomUserAgent(userAgent);
            // Setting the local file path that allows cross-domain access.
            param.webController.setPathAllowingUniversalAccess([uiContext?.getHostContext()?.resourceDir]);
          } catch (error) {
            const err: BusinessError = error as BusinessError;
            Logger.error(TAG, `Web User-Agent setting error: ${err.code}, ${err.message}.`);
          }
        })
        .width('100%')
        .height('100%')
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .onReachStart(() => {
      param.webMockScroller?.scrollEdge(Edge.Top);
    })
    .onReachEnd(() => {
      param.webMockScroller?.scrollEdge(Edge.Bottom);
      if (param.module) {
        const eventEmitter = eventEmitterMap.get(param.module);
        eventEmitter && eventEmitter(ScrollDirectionEnum.UP, 0);
      }
    })
  }
}

export class NativeActionData {
  public webSheet: (src: string, type: number) => void;
  public jumpPage: (type: string, id: number, currentIndex?: number, componentName?: string) => void;
  public imagePreviewChanged: (isShown: boolean) => void;

  constructor(url: string) {
    this.webSheet = (src: string, type: number) => {
      const sheetEvent = sheetEventMap.get(url);
      if (sheetEvent) {
        sheetEvent(src, type);
      }
    };

    this.jumpPage = (type: string, id: number, currentIndex?: number, componentName?: string) => {
      const sheetEvent = pageEventMap.get(url);
      if (sheetEvent) {
        sheetEvent(type, id, currentIndex, componentName);
      }
    }

    this.imagePreviewChanged = (isShown: boolean) => {
      const previewEvent = previewEventMap.get(url);
      if (previewEvent) {
        previewEvent(isShown);
      }
    }
  }
}

export class WebUtil {
  private static uiContext: UIContext;
  public static readonly ARTICLE_WHITE_METHODS: string[] = ['checkPreview()', 'closePreview()'];

  static addNode(url: string) {
    webNodeMap.get(url)?.add();
  }

  public static initialize(windowStage: window.WindowStage) {
    try {
      WebUtil.uiContext = windowStage.getMainWindowSync().getUIContext();
      webNodeMap.clear();
      webControllerMap.clear();
      webview.WebviewController.initializeWebEngine();
      WebUtil.createWebNode(WebUtil.getComponentCodeUrl(), WebUtil.uiContext, undefined, ModuleNameEnum.CODE_PREVIEW,
        true, false);
    } catch (err) {
      Logger.error(TAG, `WebUtil initialize failed. Cause: ${err.code} ${err.message}`);
    }
  }

  public static removeNode(url: string) {
    if (nodeRequiredMap.has(url)) {
      Logger.debug(TAG, `Web Node is Required again, should not dispose: ${url}`);
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
    try {
      const loaded: boolean = !!webLoadedMap.get(url);
      if (!loaded && NetworkUtil.hasDefaultNet()) {
        const webController = WebUtil.getWebController(url);
        AppStorage.setOrCreate(StorageKey.WEB_LOADING, true);
        webLoadedMap.set(url, true);
        webController?.refresh();
        return true;
      }
      return loaded;
    } catch {
      Logger.error(TAG, `CheckWebLoaded failed.`);
      return false;
    }
  }

  public static createWebNode(webUrl: string, uiContext?: UIContext, nestedScrollMode?: NestedScrollMode,
    module?: ModuleNameEnum, onlyWhiteMode?: boolean, verticalScrollBarAccess?: boolean) {
    if (webNodeMap.has(webUrl)) {
      nodeRequiredMap.set(webUrl, true);
      Logger.debug(TAG, `Has web node with url: ${webUrl}, should not create web node.`);
      return;
    }
    if (!WebUtil.uiContext && uiContext) {
      WebUtil.uiContext = uiContext;
    }
    Logger.debug(TAG, `initWebNode with url: ${webUrl}`);
    const webNode = new WebNodeController();
    const webController = new webview.WebviewController();
    const webMockScroller = new Scroller();
    const webBuilderParam: WebBuilderParam = {
      webUrl,
      webController,
      webMockScroller,
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
    webNode.initWebNode(WebUtil.uiContext, webBuilderParam);
    webLoadedMap.set(webUrl, NetworkUtil.hasDefaultNet());
    webControllerMap.set(webUrl, webController);
    webNodeMap.set(webUrl, webNode);
    webMockScrollerMap.set(webUrl, webMockScroller);
  }

  public static updateWebNode(webUrl: string, nestedScrollMode?: NestedScrollMode, module?: ModuleNameEnum,
    onlyWhiteMode?: boolean, verticalScrollBarAccess?: boolean) {
    const webController = webControllerMap.get(webUrl);
    if (!webController) {
      Logger.error(TAG, `updateWebNode failed. cause webController is null`);
      return;
    }
    const webMockScroller = webMockScrollerMap.get(webUrl);
    new Scroller();
    const webBuilderParam: WebBuilderParam = {
      webUrl,
      webController,
      webMockScroller,
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

  public static getWebScroller(webUrl: string): Scroller | undefined {
    return webMockScrollerMap.get(webUrl);
  }

  public static getWebController(webUrl: string): webview.WebviewController | undefined {
    return webControllerMap.get(webUrl);
  }

  public static setWebController(webUrl: string, webViewController: webview.WebviewController): void {
    webControllerMap.set(webUrl, webViewController);
  }

  public static setTrustList(webUrl: string): void {
    const webController: webview.WebviewController | undefined = webControllerMap?.get(webUrl);
    try {
      const context = WebUtil.uiContext.getHostContext();
      if (!context) {
        Logger.error(TAG, `setTrustList failed cause context is undefined.`);
        return;
      }
      const whitelist: object =
        ResourceUtil.getRawFileStringByKey(context, ConfigMapKey.WHITELIST) as object;
      const permissionList: Record<string, object> = { 'UrlPermissionList': whitelist };
      const trustStr = JSON.stringify(permissionList);
      webController?.setUrlTrustList(trustStr);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Web User-Agent setting error: ${err.code}, ${err.message}.`);
    }
  }

  public static handleLoadIntercept(event: OnLoadInterceptEvent): boolean {
    const tempUrl = event.data.getRequestUrl();
    if (!event.data.isMainFrame()) {
      return true;
    }
    if (WebUtil.checkUrl(tempUrl)) {
      return false;
    }
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: tempUrl,
      parameters: {
        'ohos.ability.params.showDefaultPicker': true
      }
    };
    const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    const context = uiContext?.getHostContext();
    if (!context) {
      Logger.error(TAG, `HandleLoadIntercept failed, cause context is undefined.`);
      return true;
    }
    ProcessUtil.startAbility(context as common.UIAbilityContext, want);
    return true;
  }

  public static checkUrl(url: string): boolean {
    const tempUri: uri.URI = new uri.URI(url);
    const res: uri.URI = tempUri.normalize();
    Logger.debug(TAG, `Web request url : ${res.toString()}`);
    const context = WebUtil.uiContext.getHostContext();
    if (!context) {
      Logger.error(TAG, `CheckUrl failed cause context is undefined.`);
      return false;
    }
    const whitelist: TrustUri[] =
      ResourceUtil.getRawFileStringByKey(context, ConfigMapKey.WHITELIST) as TrustUri[];

    const currentTrustUri = whitelist.find((item) => {
      const trustScheme: Boolean = item.scheme === res.scheme;
      if (!item.host) {
        return trustScheme;
      }
      const trustHost = (res.host || '').endsWith(item.host);
      if (!item.path) {
        return trustScheme && trustHost;
      }
      const trustPath = (res.path || '').startsWith(item.path);
      return trustScheme && trustHost && trustPath;
    });
    if (currentTrustUri) {
      return true;
    }
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

  public static setImagePreviewAction(url: string, callback: Function) {
    previewEventMap.set(url, callback);
  }

  public static upPage(url: string) {
    webNodeMap.get(url)?.add();
  }

  public static downPage(url: string) {
    webNodeMap.get(url)?.remove();
  }

  public static getComponentCodeUrl(): string {
    const context = WebUtil.uiContext.getHostContext();
    if (!context) {
      Logger.error(TAG, `GetComponentCodeUrl failed cause context is undefined.`);
      return '';
    }
    return context.resourceDir + componentCodeHtml;
  }

  public static getJsPermission(): string {
    const context = WebUtil.uiContext.getHostContext();
    if (!context) {
      Logger.error(TAG, `GetJsPermission failed cause context is undefined.`);
      return '';
    }
    const trustList: object = ResourceUtil.getRawFileStringByKey(context, ConfigMapKey.JS_WHITELIST) as object;
    const permissionStr: string = `{
      'javascriptProxyPermission': {
        'urlPermissionList': ${JSON.stringify(trustList)}
      }
    }`;
    return permissionStr;
  }
}

export class WebNodeController extends NodeController {
  private rootNode: BuilderNode<WebBuilderParam[]> | null = null;
  private isRemove: boolean = false;

  makeNode(): FrameNode | null {
    if (this.isRemove) {
      return null;
    }
    return this.rootNode?.getFrameNode() ?? null;
  }

  disposeNode() {
    if (this.rootNode) {
      this.rootNode.dispose();
      this.rootNode = null;
    }
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
      try {
        this.rootNode.update(webBuilderParam);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `Failed to update web node, ${err.code}, ${err.message}`);
      }
    }
  }
}

interface TrustUri {
  scheme: string;
  host?: string;
  path?: string;
  port?: string;
}