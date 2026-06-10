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

/**
 * Loading status enum.
 */
export enum LoadingStatus {
  IDLE = 'idle',
  OFF = 'off',
  LOADING = 'loading',
  SUCCESS = 'success',
  FAILED = 'failed',
  NO_NETWORK = 'no_network',
  EMPTY_DATA = 'empty_data',
}

/**
 * GridRow column.
 */
export enum ColumnEnum {
  SM = 4,
  MD = 8,
  LG = 12,
  XL = 12,
}

/**
 * Module name.
 */

export enum ModuleNameEnum {
  COMPONENT_LIST = 'componentListView',
  COMPONENT_DETAIL = 'componentDetailView',
  CODE_PREVIEW = 'codePreview',
  ARTICLE_DETAIL = 'articleDetail',
}

/**
 * Web component scroll direction
 */
export enum ScrollDirectionEnum {
  UP = 'up',
  DOWN = 'down'
}

export enum ProductSeriesEnum {
  HPR = 'HPR', // fordable PC
  VDE = 'VDE',
}

export enum StorageKey {
  UI_CONTEXT = 'hmos_world_UIContext',
  COLOR_MODE = 'hmos_world_SystemColorMode',
  GLOBAL_INFO = 'hmos_world_GlobalInfoModel',
  BUNDLE_INFO = 'hmos_world_BundleInfoData',
  WEB_LOADING = 'hmos_world_WebIsLoading',
  IS_PLAYING = 'hmos_world_IsPlaying',
  CURRENT_TAB = 'hmos_world_CurrentTabIndex',
  BLUE_RENDER_GROUP = 'hmos_world_BlurRenderGroup',
  COMPONENT_CONFIG = 'hmos_world_ComponentDetailConfig',
  COMPONENT_PAGE_CONTEXT = 'hmos_world_ComponentListPageContext',
  SAMPLE_PAGE_CONTEXT = 'hmos_world_SamplePageContext',
  EXPLORATION_PAGE_CONTEXT = 'hmos_world_ExplorationPageContext',
  HOME_PAGE_CONTEXT = 'hmos_world_PageContext',
  MINE_PAGE_CONTEXT = 'hmos_world_MinePageContext',
  WANT_PARAMETERS = 'hmos_world_WantParams',
  APP_TRACK_DATA = 'hmos_world_track_data',
  ACCOUNT_USER_ID = 'hmos_world_account_user_id',
  IS_IMAGE_DEFAULT_SIZE = 'hmos_world_Image_Is_Default_Size',
  // IntentFramework:
  HOME_PAGE_INTENTION = 'hmos_world_XiaoYi',
  HOME_PAGE_INTENTION_CUSTOM = 'hmos_world_XiaoYi_Custom',
  HOME_PAGE_INTENTION_CHANGED = 'hmos_world_XiaoYi_Change',
  CONTEXT_ENTRY = 'hmos_world_Context_EntryAbility',
  XIAOYI_EXTRACTED_NO_PARAM = 'hmos_world_Xiaoyi_extracted_no_param',
  IS_SIDEBAR_LAYOUT = 'hmos_world_isSideBarLayout',
}