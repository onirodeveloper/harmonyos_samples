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

import { BusinessError } from '@kit.BasicServicesKit';
import { PostTrackModel, TrackModel } from '../model/TrackModel';
import Logger from '../util/Logger';

const TAG: string = '[TrackService]';

export class TrackService {
  private constructor() {
  }

  public static postTrackData(trackDataArray: TrackModel[]): Promise<boolean> {
    const param: PostTrackModel = {
      trackData: trackDataArray
    };
    Logger.debug(TAG, JSON.stringify(param));
    return new Promise((resolve: (value: boolean) => void,
      reject: (reason?: object) => void) => {
      Promise.resolve(true)
        .then((result: boolean) => {
          resolve(result);
        })
        .catch((error: BusinessError) => {
          reject(error);
        });
    });
  }
}