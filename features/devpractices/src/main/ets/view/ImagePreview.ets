/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { GlobalInfoModel, ImageComponent, Logger, StorageKey, UrlUtil, CommonConstants } from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileUri, fileIo as fs, fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { HdsNavDestination } from '@kit.UIDesignKit';
import { BaseDetailComponent } from '@ohos/commonbusiness';
import { ImageModel } from '../model/ImageModel';
import { image } from '@kit.ImageKit';
import { ImageKnife, ImageKnifeData } from '@ohos/imageknife';
import { taskpool, util } from '@kit.ArkTS';
import { PromptAction } from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';

const TAG: string = '[ImagePreview]';

@Concurrent
function saveWebpTask(filesDir: string, data: string): string {
  let tmpFile: fileIo.File | undefined;
  try {
    let payload = data;
    const base64Prefix = 'base64,';
    const index = data.indexOf(base64Prefix);
    if (index !== -1) {
      payload = data.substring(index + base64Prefix.length);
    }
    const ext = 'webp';

    const bytes = new util.Base64Helper().decodeSync(payload.trim());
    const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);

    const fileName = `${Date.now()}.${ext}`;
    const tmpPath = `${filesDir}/${fileName}`;

    tmpFile =
      fileIo.openSync(tmpPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
    fileIo.writeSync(tmpFile.fd, buffer);

    return tmpPath;
  } catch (error) {
    return '';
  } finally {
    if (tmpFile !== undefined) {
      fileIo.closeSync(tmpFile);
    }
  }
}

@Component
export struct ImagePreview {
  @StorageProp(StorageKey.GLOBAL_INFO) @Watch('handelBreakPointChange') globalInfoModel: GlobalInfoModel =
    AppStorage.get(StorageKey.GLOBAL_INFO) ?? new GlobalInfoModel();
  @State imageModel: ImageModel = new ImageModel();
  @State isDownLoad: boolean = false;
  public url: string = '';
  private imageWidth: number = CommonConstants.DEFAULT_IMAGE_WIDTH;
  private imageHeight: number = CommonConstants.DEFAULT_IMAGE_HEIGHT;
  private imageWHRatio: number = 0;
  private imageKnifeData?: ImageKnifeData;
  private uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
  private context = this.uiContext?.getHostContext();
  private pathStack?: NavPathStack;
  private isMenuShow: boolean = false;
  private promptAction: PromptAction | undefined = this.uiContext?.getPromptAction();

  async initImageInfo(): Promise<void> {
    let imageSource: image.ImageSource | undefined;
    try {
      if (UrlUtil.isNetUrl(this.url)) {
        this.imageKnifeData = await ImageKnife.getInstance().getCacheImage(this.url);
        if (!this.imageKnifeData) {
          return;
        }
        if (this.imageKnifeData.type === 'png') {
          this.imageWidth = this.imageKnifeData.imageWidth === 0 ?
            ((this.imageKnifeData.source) as PixelMap).getImageInfoSync().size.width : this.imageKnifeData.imageWidth;
          this.imageHeight = this.imageKnifeData.imageHeight === 0 ?
            ((this.imageKnifeData.source) as PixelMap).getImageInfoSync().size.height : this.imageKnifeData.imageHeight;
        }
        this.imageWHRatio = this.imageWidth / this.imageHeight;
      } else {
        const resourceManager = this.context?.resourceManager;
        const fileData = await resourceManager?.getRawFileContent(this.url);
        imageSource = image.createImageSource(fileData?.buffer);
        const imageInfo = await imageSource.getImageInfo(0);
        this.imageWidth = imageInfo.size.width;
        this.imageHeight = imageInfo.size.height;
      }
    } catch (error) {
      Logger.info(TAG,
        `Init imageInfo failed. code: ${(error as BusinessError).code}, message: ${(error as BusinessError).message}.`);
    } finally {
      if (imageSource !== undefined) {
        imageSource.release();
      }
    }
  }

  async handelBreakPointChange() {
    if (this.globalInfoModel.deviceWidth !== this.imageModel.componentWidth ||
      this.globalInfoModel.deviceHeight !== this.imageModel.componentHeight) {
      await this.calCurrentImageInfo();
    }
  }

  async calCurrentImageInfo(): Promise<void> {
    try {
      this.imageModel.windowSize(this.globalInfoModel.deviceWidth, this.globalInfoModel.deviceHeight);
      let widthRatio = this.imageModel.componentWidth / this.imageWidth;
      let heightRatio = this.imageModel.componentHeight / this.imageHeight;

      let scaleRatio = Math.min(widthRatio, heightRatio) * 0.8;
      this.imageModel.imageWidth = this.imageWidth * scaleRatio;
      this.imageModel.imageHeight = this.imageHeight * scaleRatio;

      this.imageModel.maxScale = this.imageModel.calcFitScaleRatio({
        width: this.imageModel.imageWidth,
        height: this.imageModel.imageHeight
      }, { width: this.imageModel.componentWidth, height: this.imageModel.componentHeight });
    } catch (error) {
      Logger.error(TAG,
        `initCurrentImageInfo failed, code: ${(error as BusinessError).code}, msg: ${(error as BusinessError).message}`);
    }
  }

  private async savePixelMapToSandBoxFile(context: Context, pixelMap: PixelMap): Promise<string> {
    let tmpFile: fileIo.File | undefined;
    let packer: image.ImagePacker | undefined;
    try {
      packer = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
      const fileName = `${Date.now()}.png`;
      const dstPath = `${context.filesDir}/${fileName}`;
      tmpFile =
        await fileIo.open(dstPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      await packer.packToFile(pixelMap, tmpFile.fd, packOpts);
      return fileUri.getUriFromPath(dstPath);
    } catch (error) {
      Logger.error(TAG, `savePixelMapToSandBoxFile failed, code:
      ${(error as BusinessError).code}, msg: ${(error as BusinessError).code}}`);
      return '';
    } finally {
      if (tmpFile !== undefined) {
        await fileIo.close(tmpFile);
      }
      if (packer !== undefined) {
        packer.release();
      }
    }
  }

  private async saveWebpToSandBoxFile(context: Context, data: string): Promise<string> {
    try {
      const task = new taskpool.Task(saveWebpTask, context.filesDir, data);
      const tmpPath = await taskpool.execute(task) as string;
      if (tmpPath !== '') {
        return fileUri.getUriFromPath(tmpPath);
      }
      return '';
    } catch (error) {
      Logger.error(TAG, `saveWebpToSandBoxFile failed, code:
      ${(error as BusinessError).code}, msg: ${(error as BusinessError).code}}`);
      return '';
    }
  }

  private async getCurrentImageUri(): Promise<string> {
    if (UrlUtil.isNetUrl(this.url)) {
      try {
        if (!this.context || !this.imageKnifeData) {
          return '';
        }
        if (this.imageKnifeData.type === 'png') {
          return await this.savePixelMapToSandBoxFile(this.context, this.imageKnifeData.source as PixelMap);
        } else {
          return await this.saveWebpToSandBoxFile(this.context, this.imageKnifeData.source as string);
        }
      } catch (error) {
        const err = error as BusinessError;
        Logger.error(TAG, `getImageUri failed, code: ${err.code}, msg: ${err.message}`);
        return '';
      }
    } else {
      try {
        if (!this.context) {
          return '';
        }
        const bytes: Uint8Array = await this.context.resourceManager.getRawFileContent(this.url);
        const buf: ArrayBuffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);

        const fileName = `${Date.now()}.webp`;
        const tmpPath = `${this.context.filesDir}/${fileName}`;
        const tmp =
          await fileIo.open(tmpPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
        await fileIo.write(tmp.fd, buf);
        await fileIo.close(tmp);

        const srcUri = fileUri.getUriFromPath(tmpPath);
        return srcUri;
      } catch (error) {
        Logger.error(TAG,
          `getImageUri failed, code: ${(error as BusinessError).code}, msg: ${(error as BusinessError).code}}`);
        return '';
      }
    }
  }

  private async getNetImage(url: string): Promise<string> {
    if (!this.context) {
      return '';
    }
    let imageSource: image.ImageSource | undefined = undefined;
    let session: rcp.Session | undefined = undefined;
    try {
      const tlsOptions = {
        tlsVersion: 'TlsV1.2',
        cipherSuite: [
          'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
          'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
          'TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256',
          'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
          'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
          'TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256'
        ]
      } as rcp.TlsV12Option;
      session = rcp.createSession();
      const request: rcp.Request = new rcp.Request(url, 'GET');
      request.configuration = {
        transfer: {
          timeout: {
            connectMs: 10000,
            transferMs: 10000
          },
          assumesHTTP3Capable: true
        },
        security: {
          tlsOptions: tlsOptions
        }
      }
      const response = await session.fetch(request);
      imageSource = image.createImageSource(response.body as ArrayBuffer);
      let pixelMap = await imageSource.createPixelMap();
      return await this.savePixelMapToSandBoxFile(this.context, pixelMap);
    } catch (error) {
      Logger.error(TAG,
        `getNetImage failed, code: ${(error as BusinessError).code}, msg: ${(error as BusinessError).code}}`);
      return '';
    } finally {
      imageSource?.release();
      session?.close();
    }
  }

  private async downLoadCurrentImage(): Promise<void> {
    let srcFile: fs.File | undefined = undefined;
    let desFile: fs.File | undefined = undefined;

    try {
      let curImgUri = await this.getCurrentImageUri();
      if (curImgUri === '') {
        curImgUri = await this.getNetImage(this.url);
      }
      const srcFileUris: string[] = [
        curImgUri,
      ];
      const photoCreationConfigs: photoAccessHelper.PhotoCreationConfig[] = [
        {
          fileNameExtension: 'webp',
          photoType: photoAccessHelper.PhotoType.IMAGE,
          subtype: photoAccessHelper.PhotoSubtype.DEFAULT,
        }
      ];
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.context);
      const desFileUris: string[] =
        await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);

      desFile = await fs.open(desFileUris[0], fs.OpenMode.WRITE_ONLY);
      srcFile = await fs.open(srcFileUris[0], fs.OpenMode.READ_ONLY);
      await fs.copyFile(srcFile.fd, desFile.fd);
      this.showToast($r('app.string.download_success'));
    } catch (error) {
      Logger.error(TAG,
        `downloadImage failed, code: ${(error as BusinessError).code}, msg: ${(error as BusinessError).code}}`);
      this.showToast($r('app.string.download_failed'));
    } finally {
      if (srcFile !== undefined) {
        await fs.close(srcFile);
      }
      if (desFile !== undefined) {
        await fs.close(desFile);
      }
      this.isDownLoad = false;
    }
  }

  private showToast(message: Resource) {
    this.promptAction?.openToast({
      message: message,
      duration: 500
    })
  }

  @Builder
  MyMenu() {
    MenuItem({
      content: $r('app.string.save_image')
    })
      .onClick(() => {
        if (this.isDownLoad) {
          return;
        }
        this.isDownLoad = true;
        this.downLoadCurrentImage();
      })
  }

  @Builder
  ImagePreviewBuilder() {
    WithTheme({ colorMode: ThemeColorMode.LIGHT }) {
      Stack({ alignContent: Alignment.Center }) {
        ImageComponent({
          src: this.url,
          objectFit: ImageFit.Contain,
          alt: $r('sys.color.background_primary')
        })
          .width(this.imageModel.imageWidth)
          .height(this.imageModel.imageHeight)
          .aspectRatio(this.imageWHRatio)
          .defaultFocus(true)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .transform(this.imageModel.matrix)
          .translate({
            x: this.imageModel.curOffsetX,
            y: this.imageModel.curOffsetY
          })
          .bindContextMenu(this.MyMenu, ResponseType.LongPress, {
            onAppear: () => {
              this.isMenuShow = true;
            }
          })
      }
      .width('100%')
      .height('100%')
      .gesture(
        GestureGroup(
          GestureMode.Exclusive,
          PanGesture({ fingers: 1, distance: 3 })
            .onActionUpdate((event: GestureEvent) => {
              this.imageModel.panGestureUpdate(event);
            })
            .onActionEnd(() => {
              this.imageModel.gestureEnd();
            }),
          PinchGesture({ fingers: 2, distance: 1 })
            .onActionStart((event: GestureEvent) => {
              if (!this.isMenuShow) {
                this.isMenuShow = false;
              }
              this.imageModel.pinchGestureStart(event);
            })
            .onActionUpdate((event: GestureEvent) => {
              this.imageModel.pinchGestureUpdate(event);
            })
            .onActionEnd(() => {
              this.imageModel.pinchGestureEnd();
            }),
          TapGesture({ count: 2 })
            .onAction((event: GestureEvent) => {
              if (!this.isMenuShow) {
                this.isMenuShow = false;
              }
              this.imageModel.doubleTapGesture(event);
            }),
          TapGesture({ count: 1 })
            .onAction(() => {
              if (!this.isMenuShow) {
                this.pathStack?.pop(false);
              } else {
                this.isMenuShow = false;
              }
            }),
        ), GestureMask.Normal
      )
    }
  }

  @Builder
  DetailContentBuilder() {
    BaseDetailComponent({
      detailContentView: () => {
        this.ImagePreviewBuilder()
      },
    })
  }

  build() {
    WithTheme({ colorMode: ThemeColorMode.DARK }) {
      HdsNavDestination() {
        this.DetailContentBuilder();
      }
      .hideBackButton(false)
      .titleBar({
        style: {
          originalStyle: {
            contentStyle: {
              backIconStyle: {
                backgroundColor: $r('sys.color.comp_background_tertiary'),
                iconColor: $r('sys.color.icon_primary'),
              },
              menuStyle: {
                backgroundColor: $r('sys.color.comp_background_tertiary'),
                iconColor: $r('sys.color.icon_primary'),
              }
            }
          }
        },
        content: {
          menu: {
            value: [{
              content: {
                icon: $r('sys.symbol.download'),
                isEnabled: true,
                action: () => {
                  if (this.isDownLoad === false) {
                    this.isDownLoad = true;
                    this.downLoadCurrentImage();
                  }
                }
              }
            }]
          },
        }
      })
      .backgroundColor($r('sys.color.background_secondary'))
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
      .onBackPressed((): boolean => {
        if (this.isMenuShow) {
          this.isMenuShow = false;
        }
        if (!this.isDownLoad) {
          this.pathStack?.pop(false);
          return true;
        }
        return false;
      })
      .onReady(async (ctx: NavDestinationContext) => {
        const params: ImagePreviewParam = ctx?.pathInfo?.param as ImagePreviewParam;
        this.url = params.url;
        this.pathStack = ctx.pathStack;
        await this.initImageInfo();
        await this.calCurrentImageInfo();
      })
    }
  }
}

@Builder
export function ImagePreviewBuilder() {
  ImagePreview()
}

export interface ImagePreviewParam {
  url: string;
}