/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

export class BundleInfoData {
  public versionName: string;
  public versionCode: number;
  public bundleName: string;

  public constructor(versionName?: string, versionCode?: number, bundleName?: string) {
    this.versionName = versionName || '1.0.0';
    this.versionCode = versionCode || 1000000;
    this.bundleName = bundleName || '';
  }
}