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

import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../util/Logger';

const PREFERENCES_NAME: string = 'HMosWorldStore';
const TAG: string = '[PreferenceManager]';

export class PreferenceManager {
  private preferences?: preferences.Preferences;
  private static instance: PreferenceManager;

  private constructor() {
    this.initPreference(PREFERENCES_NAME);
  }

  public static getInstance(): PreferenceManager {
    if (!PreferenceManager.instance) {
      PreferenceManager.instance = new PreferenceManager();
    }
    return PreferenceManager.instance;
  }

  private initPreference(storeName: string): Promise<void> {
    return preferences.getPreferences(getContext(), storeName)
      .then((preferences: preferences.Preferences) => {
        this.preferences = preferences;
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `getPreferences failed, err code:${err.code},msg:${err.message}`);
      });
  }

  public async setValue<T>(key: string, value: T): Promise<void> {
    if (this.preferences) {
      this.preferences.put(key, JSON.stringify(value)).then(() => {
        this.saveValue();
      })
    } else {
      this.initPreference(PREFERENCES_NAME).then(() => {
        this.setValue<T>(key, value);
      });
    }
  }

  public async getValue<T>(key: string): Promise<T | null> {
    if (this.preferences) {
      return this.preferences.get(key, '').then((res: preferences.ValueType) => {
        let value: T | null = null;
        if (res) {
          value = JSON.parse(res as string) as T;
        }
        return value;
      });
    } else {
      return this.initPreference(PREFERENCES_NAME).then(() => {
        return this.getValue<T>(key);
      });
    }
  }

  public async hasValue(key: string): Promise<boolean> {
    if (this.preferences) {
      return this.preferences.has(key);
    } else {
      return this.initPreference(PREFERENCES_NAME).then(() => {
        return this.hasValue(key);
      });
    }
  }

  public async deleteValue(key: string): Promise<void> {
    if (this.preferences) {
      this.preferences.delete(key).then(() => {
        this.saveValue();
      });
    } else {
      this.initPreference(PREFERENCES_NAME).then(() => {
        this.deleteValue(key);
      });
    }
  }

  saveValue() {
    this.preferences?.flush();
  }
}