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

import { CommonConstants } from '../constant/CommonConstants';

export interface TextOverflowData {
  overflowStatus: boolean;
  breakWordIndex?: number;
}

export interface TextOverflowProperty {
  constraintWidth: Length;
  lineHeight: Length;
  fontSize: Length;
  fontWeight: FontWeight;
  wordBreak: WordBreak;
}

export class TextOverflowUtil {
  public static getOverflowData(uiContext: UIContext, textContent: string, maxLine: number,
    textOverflowProperty: TextOverflowProperty): TextOverflowData {
    for (let i = 0; i <= textContent.toString().length; i++) {
      const subStr: string = textContent.substring(0, i);
      const heightOfLimit: Length | undefined =
        TextOverflowUtil.getTextHeight(uiContext, subStr, textOverflowProperty, maxLine);
      const heightOfUnLimit: Length | undefined =
        TextOverflowUtil.getTextHeight(uiContext, subStr, textOverflowProperty, CommonConstants.UNLIMITED_LINES);
      if (heightOfLimit && heightOfUnLimit && heightOfLimit !== heightOfUnLimit) {
        return { overflowStatus: true, breakWordIndex: i - CommonConstants.BREAK_WORD_OFFSET };
      }
    }
    return { overflowStatus: false };
  }

  public static getTextHeight(uiContext: UIContext, textContent: string,
    textOverflowProperty: TextOverflowProperty, maxLines: number): Length | undefined {
    return uiContext?.getMeasureUtils()
      .measureTextSize({
        maxLines: maxLines,
        textContent: textContent,
        overflow: TextOverflow.Ellipsis,
        fontSize: textOverflowProperty.fontSize,
        wordBreak: textOverflowProperty.wordBreak,
        fontWeight: textOverflowProperty.fontWeight,
        lineHeight: textOverflowProperty.lineHeight,
        constraintWidth: textOverflowProperty.constraintWidth,
      })
      .height;
  }
}