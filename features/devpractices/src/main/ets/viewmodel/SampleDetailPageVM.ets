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

import type { common } from '@kit.AbilityKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';
import { moduleInstallManager } from '@kit.AppGalleryKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import {
  BaseVM,
  BaseVMEvent,
  CommonConstants,
  DynamicInstallManager,
  LoadingStatus,
  Logger,
  RequestErrorCode,
  StorageKey,
  TextOverflowData,
  TextOverflowProperty,
  TextOverflowUtil,
  Toast,
} from '@ohos/common';
import { SampleCardData, SampleDetailData, SampleDetailState } from './SampleDetailState';
import type { SingleSampleData } from '../model/SampleDetailData';
import { SampleDetailModel } from '../model/SampleDetailModel';
import { SampleDetailConstant } from '../constant/CommonConstants';
import { SampleTypeEnum } from '../common/SampleConstant';

const TAG = '[SampleDetailPageVM]';

export class SampleDetailPageVM extends BaseVM<SampleDetailState> {
  private static instance: SampleDetailPageVM;
  private sampleDetailModel = SampleDetailModel.getInstance();
  private currentPathStack?: NavPathStack;

  private constructor() {
    super(new SampleDetailState());
  }

  public static getInstance(): SampleDetailPageVM {
    if (!SampleDetailPageVM.instance) {
      SampleDetailPageVM.instance = new SampleDetailPageVM();
    }
    return SampleDetailPageVM.instance;
  }

  public sendEvent(baseVMEvent: BaseVMEvent): void {
    if (baseVMEvent instanceof TerminateTaskEvent) {
      this.terminateTask(baseVMEvent);
    } else if (baseVMEvent instanceof LoadSampleEvent) {
      this.loadSample();
    } else if (baseVMEvent instanceof ChangeDownloadProgressEvent) {
      this.changeDownloadProgress(baseVMEvent);
    } else if (baseVMEvent instanceof BindSheetEvent) {
      this.changeBindSheet(baseVMEvent);
    } else if (baseVMEvent instanceof PopEvent) {
      this.pop();
    } else if (baseVMEvent instanceof SetIndexEvent) {
      this.setCurrentIndex(baseVMEvent);
    } else if (baseVMEvent instanceof SetInstalledEvent) {
      this.setInstalledStatus(baseVMEvent);
    } else if (baseVMEvent instanceof InitSampleDetailEvent) {
      this.initSampleDetail(baseVMEvent);
    } else if (baseVMEvent instanceof AssignPathStackEvent) {
      this.currentPathStack = baseVMEvent.navPathStack;
    } else if (baseVMEvent instanceof SetOverflowStatusEvent) {
      this.setOverflowStatus(baseVMEvent);
    } else if (baseVMEvent instanceof ChangeCardStatusEvent) {
      this.changeCardStatus(baseVMEvent);
    } else if (baseVMEvent instanceof ChangeBackPressed) {
      this.changeBackPressedState(baseVMEvent.backPressed);
    }
  }

  private changeBackPressedState(backPressed: boolean) {
    this.state.isBackPressed = backPressed;
  }

  private initSampleDetail(event: InitSampleDetailEvent): void {
    this.state.loadingStatus = LoadingStatus.LOADING;
    this.state.currentIndex = event.currentIndex;
    this.state.downloadingStatus = false;
    this.state.installingStatus = false;
    this.initSampleData(event.id, event.sampleCardId, event.unionId);
  }

  private setInstalledStatus(event: SetInstalledEvent): void {
    if (DynamicInstallManager.getModuleStatus(this.state.sampleDatas[event.sampleIndex].sampleCard.moduleName) ===
      moduleInstallManager.InstallStatus.INSTALLED) {
      this.setSampleInstalledStatus(event.sampleIndex, true);
    }
  }

  private setCurrentIndex(event: SetIndexEvent): void {
    this.state.currentIndex = event.currentIndex;
  }

  private terminateTask(event: TerminateTaskEvent): void {
    if (this.state.installingStatus) {
      Toast.showToast($r('app.string.installing_status'));
    } else if (this.state.downloadingStatus) {
      DynamicInstallManager.cancelDownloadTask(this.state.taskId);
      this.state.taskId = '';
      this.setSampleDownloadingStatus(event.sampleIndex, false, -1);
      this.setInstallingStatus(false);
      Logger.info(TAG, 'cancelDownloadListener success');
    }
  }

  private changeDownloadProgress(event: ChangeDownloadProgressEvent): void {
    this.state.sampleDatas[event.sampleIndex].sampleCard.downloadProgress = event.downloadProgress;
  }

  private changeBindSheet(event: BindSheetEvent): void {
    this.state.sampleDatas[event.sampleIndex].sampleCard.bindSheetShow = event.dataValue;
  }

  private pop(): void {
    if (this.state.installingStatus) {
      Toast.showToast($r('app.string.installing_status'));
    } else {
      this.changeBackPressedState(true);
      if (this.state.downloadingStatus) {
        this.state.downloadingStatus = false;
        DynamicInstallManager.cancelDownloadTask(this.state.taskId);
        this.state.taskId = '';
      }
      emitter.off(CommonConstants.DYNAMIC_INSTALL_EVENT);
      Logger.info(TAG, 'cancelDownloadListener success');
      this.currentPathStack?.pop();
    }
  }

  private initSampleData(sampleId: number, sampleCardId: number, unionId: number): void {
    const sampleDetailData: SampleDetailData[] = [];
    this.state.sampleDatas = [];
    const cardId: number = unionId || sampleCardId;
    const isUnion: boolean = unionId ? true : false;
    this.sampleDetailModel.getSampleCardDetails(sampleId, cardId, isUnion)
      .then((result: SingleSampleData[]) => {
        this.state.sampleCount = result.length;
        result.forEach((singleSampleData: SingleSampleData) => {
          const sampleData: SampleDetailData = new SampleDetailData();
          sampleData.sampleCard = new SampleCardData();
          sampleData.id = sampleData.sampleCard.sampleId = singleSampleData.id;
          sampleData.isFavorite = singleSampleData.isFavorite;
          sampleData.mediaInfoList = singleSampleData.mediaInfoList;
          sampleData.sampleCard.title = singleSampleData.title;
          sampleData.sampleCard.installed = singleSampleData.preInstalled;
          sampleData.sampleCard.type = singleSampleData.type;
          sampleData.sampleCard.desc = singleSampleData.desc;
          sampleData.sampleCard.originalUrl = singleSampleData.originalUrl;
          sampleData.sampleCard.moduleName = singleSampleData.moduleName;
          sampleData.sampleCard.abilityName = singleSampleData.abilityName;
          sampleData.sampleCard.apiVersion = singleSampleData.apiVersion;
          if (DynamicInstallManager.getModuleStatus(sampleData.sampleCard.moduleName) ===
            moduleInstallManager.InstallStatus.INSTALLED) {
            sampleData.sampleCard.installed = true;
          }
          sampleDetailData.push(sampleData);
        });
        this.state.sampleDatas = sampleDetailData;
        this.initDownloadListener();
      })
      .catch((error: BusinessError) => {
        if (error.code === RequestErrorCode.NETWORK_CONNECT_FAILED) {
          this.state.loadingStatus = LoadingStatus.NO_NETWORK;
        } else {
          this.state.loadingStatus = LoadingStatus.FAILED;
        }
      });
  }

  private initDownloadListener(): void {
    emitter.on(CommonConstants.DYNAMIC_INSTALL_EVENT, (eventData) => {
      const data = eventData.data;
      Logger.debug(TAG,
        `downloadedSize: ${data?.downloadedSize}, totalSize:${data?.totalSize}, status: ${data?.taskStatus}`);
      if (data?.taskStatus === moduleInstallManager.TaskStatus.DOWNLOADING) {
        if (data?.downloadedSize === data?.totalSize) {
          this.setInstallingStatus(true);
        }
        this.setSampleDownloadingStatus(this.state.currentIndex, true,
          Math.floor(((data?.downloadedSize ?? SampleDetailConstant.PROGRESS_START) /
            (data?.totalSize ?? SampleDetailConstant.PROGRESS_FINISH)) *
          SampleDetailConstant.PROGRESS_FINISH));
        Logger.debug(TAG,
          `loadSampleCallback downloading progress: ${this.state.sampleDatas[this.state.currentIndex].sampleCard.downloadProgress}`);
      } else if (data?.taskStatus === moduleInstallManager.TaskStatus.INSTALL_SUCCESSFUL) {
        this.setSampleDownloadingStatus(this.state.currentIndex, false, -1);
        this.setInstallingStatus(false);
        this.setSampleInstalledStatus(this.state.currentIndex, true);
        const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
        const context: common.UIAbilityContext = uiContext?.getHostContext() as common.UIAbilityContext;
        if (!context) {
          Logger.error(TAG, `LoadModule failed. cause context is undefined.`);
          return;
        }
        DynamicInstallManager.loadModule(context,
          this.state.sampleDatas[this.state.currentIndex].sampleCard.abilityName);
        Logger.info(TAG,
          `loadSampleCallback installed : ${this.state.sampleDatas[this.state.currentIndex].sampleCard.abilityName}`);
      } else if (data?.taskStatus === moduleInstallManager.TaskStatus.INSTALL_WAITING ||
        data?.taskStatus === moduleInstallManager.TaskStatus.INSTALLING) {
        Logger.info(TAG, `loadSampleCallback installing`);
      } else if (data?.taskStatus === moduleInstallManager.TaskStatus.DOWNLOAD_SUCCESSFUL) {
        Logger.info(TAG, `loadSampleCallback download success`);
      } else if (data?.taskStatus === moduleInstallManager.TaskStatus.TASK_UNFOUND) {
        this.setSampleDownloadingStatus(this.state.currentIndex, false, -1);
        this.setInstallingStatus(false);
        Logger.info(TAG, 'loadSampleCallback task unfound');
      }
    });
    Logger.info(TAG, 'initDownloadListener success');
  }

  private loadSample(): void {
    if (this.state.currentIndex < 0 || !this.state.sampleDatas[this.state.currentIndex]) {
      return;
    }
    const currentSampleType = this.state.sampleDatas[this.state.currentIndex].sampleCard.type;
    if (this.state.sampleDatas[this.state.currentIndex].sampleCard.apiVersion > deviceInfo.sdkApiVersion) {
      Toast.showToast($r('app.string.api_prompt'));
    } else if (currentSampleType === SampleTypeEnum.COMMON_CLIENT) {
      Toast.showToast($r('app.string.client_prompt'));
    } else if (currentSampleType === SampleTypeEnum.WEARABLE_CLIENT) {
      Toast.showToast($r('app.string.watch_prompt'));
    } else {
      this.startTask();
    }
  }

  private startTask(): void {
    const abilityName = this.state.sampleDatas[this.state.currentIndex].sampleCard.abilityName;
    const moduleName = this.state.sampleDatas[this.state.currentIndex].sampleCard.moduleName;
    if (moduleName === '' || !moduleName || abilityName === '' || !abilityName) {
      Toast.showToast($r('app.string.device_prompt'));
      return;
    }
    if (this.state.sampleDatas[this.state.currentIndex].sampleCard.installed) {
      try {
        const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
        const context: common.UIAbilityContext = uiContext?.getHostContext() as common.UIAbilityContext;
        if (!context) {
          Logger.error(TAG, `Failed to loadModule, cause context is undefined`);
          return;
        }
        DynamicInstallManager.loadModule(context,
          this.state.sampleDatas[this.state.currentIndex].sampleCard.abilityName);
      } catch (error) {
        Logger.error(TAG, `Failed to loadModule, error code: ${error.code}, error data: ${error.message}`);
      }
    } else {
      //Init progress listener
      DynamicInstallManager.subscribeDownloadProgress();
      this.setSampleDownloadingStatus(this.state.currentIndex, false, -1);
      connection.getDefaultNet().then((netHandle: connection.NetHandle) => {
        connection.getNetCapabilities(netHandle).then((data: connection.NetCapabilities) => {
          Logger.debug(TAG, `succeeded to get connection data: ${data.bearerTypes[0]}`);
          if (data.bearerTypes[0] === connection.NetBearType.BEARER_WIFI) {
            this.setSampleDownloadingStatus(this.state.currentIndex, true, 0);
          }
        }).catch((error: BusinessError) => {
          Logger.error(TAG, `Failed to getNetCapabilities, error code: ${error.code}, error data: ${error.message}`);
        })
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Failed to get connection error code: ${error.code}, error data: ${error.message}`);
      });
      this.startDownload();
    }
  }

  private startDownload(): void {
    Logger.info(TAG, `start download sample: ${this.state.sampleDatas[this.state.currentIndex].sampleCard.title}`);
    const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
    const context: common.UIAbilityContext = uiContext?.getHostContext() as common.UIAbilityContext;
    DynamicInstallManager.fetchModule(context, this.state.sampleDatas[this.state.currentIndex].sampleCard.moduleName)
      .then((data: moduleInstallManager.ModuleInstallSessionState) => {
        if (data.code === moduleInstallManager.RequestErrorCode.SUCCESS) {
          this.state.taskId = data.taskId;
        } else if (data.code === moduleInstallManager.RequestErrorCode.DOWNLOAD_WAIT_WIFI) {
          if (!context) {
            Logger.error(TAG, `Failed to fetchModule. cause context is undefined`);
            return;
          }
          try {
            moduleInstallManager.showCellularDataConfirmation(context, data.taskId);
          } catch (error) {
            Logger.error(TAG, `ShowCellularDataConfirmation failed. Cause code: ${error.code}, msg: ${error.message}`);
          }
          this.state.taskId = data.taskId;
        } else {
          if (data.code === moduleInstallManager.RequestErrorCode.MODULE_UNAVAILABLE) {
            Toast.showToast($r('app.string.module_nonexistent'));
          } else if (data.code === moduleInstallManager.RequestErrorCode.NETWORK_ERROR) {
            Toast.showToast($r('app.string.internet_error'));
          } else if (data.code === moduleInstallManager.RequestErrorCode.INVALID_REQUEST) {
            Toast.showToast($r('app.string.requestinfo_error'));
          }
          this.setSampleDownloadingStatus(this.state.currentIndex, false, -1);
        }
      }).catch((error: BusinessError) => {
      Logger.error(TAG, `Failed to fetchModule. error code: ${error.code}, error data: ${error.message}`);
    });
  }

  private setSampleDownloadingStatus(sampleIndex: number, downloading: boolean, progress: number): void {
    this.state.sampleDatas[sampleIndex].sampleCard.downloading = downloading;
    this.state.sampleDatas[sampleIndex].sampleCard.downloadProgress = progress;
    this.state.downloadingStatus = downloading;
  }

  private setSampleInstalledStatus(sampleIndex: number, installed: boolean): void {
    this.state.sampleDatas[sampleIndex].sampleCard.installed = installed;
  }

  private setInstallingStatus(installing: boolean): void {
    this.state.installingStatus = installing;
  }

  private setOverflowStatus(event: SetOverflowStatusEvent) {
    this.reSetOverflowStatus(event.indexOfSwiper);
    const textOverflowOptions: TextOverflowProperty = {
      constraintWidth: event.area.width,
      fontSize: $r('sys.float.Subtitle_S'),
      fontWeight: FontWeight.Regular,
      lineHeight: $r('app.float.cardsubtitle_lineheight'),
      wordBreak: WordBreak.BREAK_ALL,
    };
    const textOverflowData: TextOverflowData =
      TextOverflowUtil.getOverflowData(event.uiContext, this.state.sampleDatas[event.indexOfSwiper].sampleCard.desc,
        SampleDetailConstant.SUBTITLE_MAXLINE, textOverflowOptions);
    this.state.sampleDatas[event.indexOfSwiper].sampleCard.isOverflow = textOverflowData.overflowStatus;
    this.state.loadingStatus = LoadingStatus.SUCCESS;
  }

  private reSetOverflowStatus(indexOfSwiper: number) {
    this.state.sampleDatas[indexOfSwiper].sampleCard.isOverflow = false;
    this.state.sampleDatas[indexOfSwiper].sampleCard.breakWordIndex = 0;
  }

  private changeCardStatus(event: ChangeCardStatusEvent): void {
    this.state.sampleDatas[event.indexOfSwiper].sampleCard.cardOpenStatus =
      !this.state.sampleDatas[event.indexOfSwiper].sampleCard.cardOpenStatus;
  }
}

export class BindSheetEvent implements BaseVMEvent {
  public readonly sampleIndex: number;
  public readonly dataValue: boolean;

  public constructor(sampleIndex: number, dataValue: boolean) {
    this.sampleIndex = sampleIndex;
    this.dataValue = dataValue;
  }
}

export class ChangeSampleDataEvent implements BaseVMEvent {
  public readonly sampleCardId: number;

  public constructor(sampleCardId: number) {
    this.sampleCardId = sampleCardId;
  }
}

export class TerminateTaskEvent implements BaseVMEvent {
  public readonly sampleIndex: number;

  public constructor(sampleIndex: number) {
    this.sampleIndex = sampleIndex;
  }
}

export class LoadSampleEvent implements BaseVMEvent {
}

export class ChangeDownloadProgressEvent implements BaseVMEvent {
  public readonly sampleIndex: number;
  public readonly downloadProgress: number;

  public constructor(sampleIndex: number, downloadProgress: number) {
    this.sampleIndex = sampleIndex;
    this.downloadProgress = downloadProgress;
  }
}

export class PopEvent implements BaseVMEvent {
}

export class SetOverflowStatusEvent implements BaseVMEvent {
  public readonly uiContext: UIContext;
  public readonly area: Area;
  public readonly indexOfSwiper: number;

  public constructor(uiContext: UIContext, area: Area, indexOfSwiper: number) {
    this.uiContext = uiContext;
    this.area = area;
    this.indexOfSwiper = indexOfSwiper;
  }
}

export class ChangeCardStatusEvent implements BaseVMEvent {
  public readonly indexOfSwiper: number;

  public constructor(indexOfSwiper: number) {
    this.indexOfSwiper = indexOfSwiper;
  }
}

export class SetIndexEvent implements BaseVMEvent {
  public readonly currentIndex: number;

  public constructor(currentIndex: number) {
    this.currentIndex = currentIndex;
  }
}

export class SetInstalledEvent implements BaseVMEvent {
  public readonly sampleIndex: number;

  public constructor(sampleIndex: number) {
    this.sampleIndex = sampleIndex;
  }
}

export class InitSampleDetailEvent implements BaseVMEvent {
  public readonly id: number;
  public readonly sampleCardId: number;
  public readonly currentIndex: number;
  public readonly unionId: number;

  public constructor(id: number, sampleCardId: number, currentIndex: number, unionId?: number) {
    this.id = id;
    this.sampleCardId = sampleCardId;
    this.currentIndex = currentIndex;
    this.unionId = unionId || 0;
  }
}

export class AssignPathStackEvent implements BaseVMEvent {
  public readonly navPathStack: NavPathStack;

  constructor(navPathStack: NavPathStack) {
    this.navPathStack = navPathStack;
  }
}

export class ChangeBackPressed implements BaseVMEvent {
  public readonly backPressed: boolean;

  constructor(backPressed: boolean) {
    this.backPressed = backPressed;
  }
}