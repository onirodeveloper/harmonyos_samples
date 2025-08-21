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
import { moduleInstallManager } from '@kit.StoreKit';
import {
  BaseVM,
  BaseVMEvent,
  BreakpointTypeEnum,
  CommonConstants,
  DynamicInstallManager,
  GlobalInfoModel,
  LoadingStatus,
  Logger,
  PageContext,
  StorageKey,
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
    }
  }

  private initSampleDetail(event: InitSampleDetailEvent): void {
    this.state.loadingStatus = LoadingStatus.LOADING;
    this.state.currentIndex = event.currentIndex;
    this.state.downloadingStatus = false;
    this.state.installingStatus = false;
    this.initSampleData(event.sampleCardId);
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
    if (this.state.downloadingStatus) {
      DynamicInstallManager.cancelDownloadTask(this.state.taskId);
    }
    this.state.taskId = '';
    this.setSampleDownloadingStatus(event.sampleIndex, false, -1);
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
      this.state.isBackPressed = true;
      if (this.state.downloadingStatus) {
        this.state.downloadingStatus = false;
        DynamicInstallManager.cancelDownloadTask(this.state.taskId);
        this.state.taskId = '';
      }
      emitter.off(CommonConstants.DYNAMIC_INSTALL_EVENT);
      Logger.info(TAG, 'cancelDownloadListener success');
      const globalInfoModel: GlobalInfoModel = AppStorage.get(StorageKey.GLOBAL_INFO)!;
      const pageContext: PageContext =
        globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? AppStorage.get(StorageKey.SAMPLE_PAGE_CONTEXT)! :
          AppStorage.get(StorageKey.HOME_PAGE_CONTEXT) as PageContext;
      pageContext.popPage();
    }
  }

  private initSampleData(sampleCardId: number): void {
    const sampleDetailData: SampleDetailData[] = [];
    this.state.sampleDatas = [];
    this.sampleDetailModel.getSampleCardDetails(sampleCardId).then((result: SingleSampleData[]) => {
      this.state.sampleCount = result.length;
      result.forEach((singleSampleData: SingleSampleData) => {
        const sampleData: SampleDetailData = new SampleDetailData();
        sampleData.sampleCard = new SampleCardData();
        sampleData.id = sampleData.sampleCard.sampleId = singleSampleData.id;
        sampleData.isFavorite = singleSampleData.isFavorite;
        sampleData.mediaUrl = singleSampleData.mediaUrl;
        sampleData.mediaType = singleSampleData.mediaType;
        sampleData.sampleCard.title = singleSampleData.title;
        sampleData.sampleCard.installed = singleSampleData.preInstalled;
        sampleData.sampleCard.sampleType = singleSampleData.sampleType;
        sampleData.sampleCard.desc = singleSampleData.desc;
        sampleData.sampleCard.originalUrl = singleSampleData.originalUrl;
        sampleData.sampleCard.moduleName = singleSampleData.moduleName;
        sampleData.sampleCard.abilityName = singleSampleData.abilityName;
        if (DynamicInstallManager.getModuleStatus(sampleData.sampleCard.moduleName) ===
        moduleInstallManager.InstallStatus.INSTALLED) {
          sampleData.sampleCard.installed = true;
        }
        sampleDetailData.push(sampleData);
      });
      this.state.sampleDatas = sampleDetailData;
      this.initDownloadListener();
      this.state.loadingStatus = LoadingStatus.SUCCESS;
    }).catch(() => {
      this.state.loadingStatus = LoadingStatus.FAILED;
    });
  }

  private initDownloadListener(): void {
    emitter.on(CommonConstants.DYNAMIC_INSTALL_EVENT, (eventData) => {
      if (eventData.data?.taskStatus === moduleInstallManager.TaskStatus.DOWNLOADING) {
        if (eventData.data?.downloadedSize === eventData.data?.totalSize) {
          this.setInstallingStatus(true);
        }
        this.setSampleDownloadingStatus(this.state.currentIndex, true,
          Math.floor(((eventData.data?.downloadedSize ?? SampleDetailConstant.PROGRESS_START) /
            (eventData.data?.totalSize ?? SampleDetailConstant.PROGRESS_FINISH)) *
          SampleDetailConstant.PROGRESS_FINISH));
        Logger.info(TAG, `loadSampleCallback downloading size: ${eventData.data?.downloadedSize}`);
      } else if (eventData.data?.taskStatus === moduleInstallManager.TaskStatus.INSTALL_SUCCESSFUL) {
        this.setSampleInstalledStatus(this.state.currentIndex, true);
        this.setSampleDownloadingStatus(this.state.currentIndex, false, -1);
        this.setInstallingStatus(false);
        const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
        const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
        DynamicInstallManager.loadModule(context,
          this.state.sampleDatas[this.state.currentIndex].sampleCard.abilityName);
        Logger.info(TAG,
          `loadSampleCallback installed : ${this.state.sampleDatas[this.state.currentIndex].sampleCard.abilityName}`);
      } else if (eventData.data?.taskStatus === moduleInstallManager.TaskStatus.INSTALL_WAITING ||
        eventData.data?.taskStatus === moduleInstallManager.TaskStatus.INSTALLING) {
        this.setInstallingStatus(true);
        Logger.info(TAG, `loadSampleCallback installing`);
      } else if (eventData.data?.taskStatus === moduleInstallManager.TaskStatus.TASK_UNFOUND) {
        DynamicInstallManager.unsubscribeDownloadProgress();
      }
    });
    Logger.info(TAG, 'initDownloadListener success');
  }

  private loadSample(): void {
    if (this.state.currentIndex < 0 || !this.state.sampleDatas[this.state.currentIndex]) {
      return;
    }
    const currentSampleType = this.state.sampleDatas[this.state.currentIndex].sampleCard.sampleType;
    if (currentSampleType === SampleTypeEnum.COMMON_CLIENT) {
      Toast.showToast($r('app.string.client_prompt'));
    } else if (currentSampleType === SampleTypeEnum.WEARABLE_CLIENT) {
      Toast.showToast($r('app.string.watch_prompt'));
    } else {
      this.startTask();
    }
  }

  private startTask(): void {
    if (this.state.sampleDatas[this.state.currentIndex].sampleCard.installed) {
      const uiContext: UIContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT) as UIContext;
      const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
      try {
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
          Logger.info(TAG, `succeeded to get connection data: ${data.bearerTypes[0]}`);
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
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    DynamicInstallManager.fetchModule(context, this.state.sampleDatas[this.state.currentIndex].sampleCard.moduleName)
      .then((data: moduleInstallManager.ModuleInstallSessionState) => {
        if (data.code === moduleInstallManager.RequestErrorCode.SUCCESS) {
          this.state.taskId = data.taskId;
        } else if (data.code === moduleInstallManager.RequestErrorCode.DOWNLOAD_WAIT_WIFI) {
          moduleInstallManager.showCellularDataConfirmation(context, data.taskId);
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
  public readonly sampleCardId: number;
  public readonly currentIndex: number;

  public constructor(sampleCardId: number, currentIndex: number) {
    this.sampleCardId = sampleCardId;
    this.currentIndex = currentIndex;
  }
}