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

export class FormatDate {
  private static readonly HOUR: number = 12;

  public static formatDate(date: Date = new Date(), format: string = 'YYYY-MM-DD HH:mm:ss') {
    const d = new Date(date);
    const replacements = {
      'YYYY': d.getFullYear(),
      'YY': String(d.getFullYear()).slice(-2),
      'MM': String(d.getMonth() + 1).padStart(2, '0'),
      'M': d.getMonth() + 1,
      'DD': String(d.getDate()).padStart(2, '0'),
      'D': d.getDate(),
      'HH': String(d.getHours()).padStart(2, '0'),
      'H': d.getHours(),
      'hh': String(d.getHours() % FormatDate.HOUR || FormatDate.HOUR).padStart(2, '0'),
      'h': d.getHours() % FormatDate.HOUR || FormatDate.HOUR,
      'mm': String(d.getMinutes()).padStart(2, '0'),
      'm': d.getMinutes(),
      'ss': String(d.getSeconds()).padStart(2, '0'),
      's': d.getSeconds(),
      'SSS': String(d.getMilliseconds()).padStart(3, '0'),
      'A': d.getHours() < FormatDate.HOUR ? 'AM' : 'PM',
      'a': d.getHours() < FormatDate.HOUR ? 'am' : 'pm',
    } as DateFormat;
    return format.replace(/YYYY|YY|MM|M|DD|D|HH|H|hh|h|mm|m|ss|s|SSS|A|a/g, (match: string): string => {
      return Reflect.get(replacements, match);
    });
  }
}

interface DateFormat {
  YYYY: number,
  YY: string,
  MM: string,
  M: number,
  DD: string,
  D: number,
  HH: string,
  H: number,
  hh: string,
  h: number,
  mm: string,
  m: number,
  ss: string,
  s: number,
  SSS: string,
  A: string,
  a: string,
}