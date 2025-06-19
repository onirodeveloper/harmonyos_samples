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

class PlacementPosition {
  public code: string;
  public value: Placement;

  constructor(code: string, value: Placement) {
    this.code = code;
    this.value = value;
  }
}

export const placementMapData: Map<string, PlacementPosition> = new Map([
  ['Default', new PlacementPosition('Placement.Bottom', Placement.Bottom)],
  ['Left', new PlacementPosition('Placement.Left', Placement.Left)],
  ['Right', new PlacementPosition('Placement.Right', Placement.Right)],
  ['Top', new PlacementPosition('Placement.Top', Placement.Top)],
  ['Bottom', new PlacementPosition('Placement.Bottom', Placement.Bottom)],
  ['TopLeft', new PlacementPosition('Placement.TopLeft', Placement.TopLeft)],
  ['TopRight', new PlacementPosition('Placement.TopRight', Placement.TopRight)],
  ['BottomLeft', new PlacementPosition('Placement.BottomLeft', Placement.BottomLeft)],
  ['BottomRight', new PlacementPosition('Placement.BottomRight', Placement.BottomRight)],
  ['LeftTop', new PlacementPosition('Placement.LeftTop', Placement.LeftTop)],
  ['LeftBottom', new PlacementPosition('Placement.LeftBottom', Placement.LeftBottom)],
  ['RightTop', new PlacementPosition('Placement.RightTop', Placement.RightTop)],
  ['RightBottom', new PlacementPosition('Placement.RightBottom', Placement.RightBottom)],
]);

export enum PopupStyle {
  STYLE_BUTTON = 1,
  STYLE_TEXT = 2,
  STYLE_ICON = 3,
}

export const popupStyleMapData: Map<string, PopupStyle> = new Map([
  ['Default', PopupStyle.STYLE_BUTTON],
  ['按钮气泡', PopupStyle.STYLE_BUTTON],
  ['文字气泡', PopupStyle.STYLE_TEXT],
  ['图文气泡', PopupStyle.STYLE_ICON],
]);

export const popupStyleCodeMapData: Map<PopupStyle, string> = new Map([
  [PopupStyle.STYLE_BUTTON, `Popup({
        title: {
          text: '标题',
        },
        message: {
          text: '这是一个带按钮的气泡'
        },
        showClose: true,
        onClose: () => {
          this.handlePopup = false;
        },
        buttons: [
          {
            text: '知道了',
            action: () => {
              this.handlePopup = false;
            },
          },
        ]
      })`],
  [PopupStyle.STYLE_TEXT, `Popup({
        message: {
          text: '这是一个文字气泡'
        },
        showClose: true,
        onClose: () => {
          this.handlePopup = false;
        }
      })`],
  [PopupStyle.STYLE_ICON, `Popup({
        icon: {
          // Replace the resource images under src/main/resources/base/media in your own project.
          image: $r('app.media.startIcon')
        },
        title: {
          text: '标题',
        },
        message: {
          text: '这是一个带图标的弹出气泡'
        },
        showClose: true,
        onClose: () => {
        this.handlePopup = false;
        }
      })`],
]);

export const popupBtnTextCodeMapData: Map<PopupStyle, Resource> = new Map([
  [PopupStyle.STYLE_BUTTON, $r('app.string.popup_button_button')],
  [PopupStyle.STYLE_TEXT, $r('app.string.popup_button_text')],
  [PopupStyle.STYLE_ICON, $r('app.string.popup_button_icon')],
]);