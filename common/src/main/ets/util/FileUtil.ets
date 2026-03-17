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

import { fileIo } from '@kit.CoreFileKit';
import Logger from './Logger';

const TAG: string = '[FileUtil]';

export class FileUtil {
  private static readonly MAX_PATH_LENGTH: number = 255;
  public static readonly separator: string = '/';

  public static isFileExist(filePath: string): boolean {
    if (FileUtil.isInvalidPath(filePath)) {
      Logger.error(TAG, 'FilePath is invalid');
      return false;
    }
    try {
      return fileIo.accessSync(filePath);
    } catch (error) {
      Logger.error(TAG, `access filePath error. ${error.message}`);
      return false;
    }
  }

  public static isDirExist(dirPath: string): boolean {
    if (FileUtil.isInvalidPath(dirPath)) {
      Logger.error(TAG, 'DirPath is invalid');
      return false;
    }
    try {
      return (fileIo.statSync(dirPath).isDirectory());
    } catch (error) {
      Logger.error(TAG, `check isDirExist error. ${error.message}`);
      return false;
    }
  }

  public static makeDir(dirPath: string): boolean {
    if (FileUtil.isInvalidPath(dirPath)) {
      Logger.error(TAG, 'DirPath is invalid');
      return false;
    }
    try {
      if (!FileUtil.isDirExist(dirPath)) {
        fileIo.mkdirSync(dirPath);
      }
      return true;
    } catch (error) {
      Logger.error(TAG, `makeDir fileIo.mkdirSync error. ${error.message}`);
      return false;
    }
  }

  public static isInvalidPath(path: string | null | undefined): boolean {
    return (!path || (path.length === 0) || (path.length > FileUtil.MAX_PATH_LENGTH) || path.includes('../'));
  }
}
