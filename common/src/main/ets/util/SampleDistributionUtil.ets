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
import { deviceInfo } from '@kit.BasicServicesKit';

export class SampleDistributionUtil {
  public static checkSampleSupport(requiredApiVersion: number, supportDeviceList: string[]): boolean {
    return SampleDistributionUtil.checkApiVersionSupport(requiredApiVersion) &&
    SampleDistributionUtil.checkDeviceTypeSupport(supportDeviceList);
  }

  public static checkApiVersionSupport(requiredApiVersion: number): boolean {
    return requiredApiVersion <= deviceInfo.sdkApiVersion;
  }

  public static checkDeviceTypeSupport(supportDeviceList: string[]): boolean {
    return supportDeviceList.includes(deviceInfo.deviceType);
  }
}