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

import { DetailPageConstant } from '../../../../constant/DetailPageConstant';

class CalendarAlignMapping {
  public readonly code: string;
  public readonly value: CalendarAlign;

  constructor(code: string, value: CalendarAlign) {
    this.code = code;
    this.value = value;
  }
}

export const calendarAlignTypeMapData: Map<string, CalendarAlignMapping> = new Map([
  ['End', new CalendarAlignMapping('CalendarAlign.END', CalendarAlign.END)],
  ['Start', new CalendarAlignMapping('CalendarAlign.START', CalendarAlign.START)],
  ['Center', new CalendarAlignMapping('CalendarAlign.CENTER', CalendarAlign.CENTER)],
  ['Default', new CalendarAlignMapping('CalendarAlign.END', CalendarAlign.END)],
]);

export interface EdgeAlign {
  alignType: CalendarAlign;
  offset?: Offset;
}

export const edgeAlignDefault: EdgeAlign = { alignType: CalendarAlign.END, offset: { dx: 0, dy: 0 } };

export const textStyleDefault: PickerTextStyle = {
  color: $r('app.color.calender_default_text_color'),
  font: { size: DetailPageConstant.CALENDAR_DEFAULT_FONT_SIZE, weight: FontWeight.Normal },
};

