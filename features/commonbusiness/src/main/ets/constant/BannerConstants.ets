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

export class BannerConstants {
  public static readonly PROGRESS_VALUE_MAX: number = 2300;
  /**
   * The frame rate of the animation is 30fps.
   */
  private static readonly FRAME_RATE: number = 30;
  /**
   * The time it takes for one frame.
   */
  public static readonly FRAME_TIME: number = 1000 / BannerConstants.FRAME_RATE;
}