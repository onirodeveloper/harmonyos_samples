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
}

/**
 * GridRow column.
 */
export enum ColumnEnum {
  SM = 4,
  MD = 8,
  LG = 12,
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