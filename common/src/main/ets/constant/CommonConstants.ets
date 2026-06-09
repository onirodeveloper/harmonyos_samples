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

export class CommonConstants {
  // device aspect threshold
  public static ASPECT_LANDSCAPE_SQUARE: number = 9 / 7.2;
  public static ASPECT_SQUARE_PORTRAIT: number = 9 / 10.8;
  public static ASPECT_PORTRAIT_NARROW: number = 9 / 18;
  // Banner aspect
  public static BANNER_ASPECT_SM: number = 1.28;
  public static BANNER_ASPECT_MD: number = 0.53;
  public static BANNER_ASPECT_LG: number = 0.53;
  public static BANNER_ASPECT_XL: number = 0.56;
  public static BANNER_ASPECT_PORTRAIT: number = 0.58;
  public static NAVIGATION_HEIGHT: number = 56;
  public static TAB_BAR_HEIGHT: number = 56;
  public static TOOL_BAR_HEIGHT: number = 48;
  public static TAB_BAR_WIDTH: number = 96;
  public static SIDE_BAR_WIDTH: number = 240;
  // Percent
  public static readonly FULL_PERCENT: string = '100%';
  public static readonly HALF_PERCENT: string = '50%';
  public static readonly AUTO_FIT: string = 'auto';
  // Space
  public static readonly SPACE_2: number = 2;
  public static readonly SPACE_4: number = 4;
  public static readonly SPACE_6: number = 6;
  public static readonly SPACE_8: number = 8;
  public static readonly SPACE_10: number = 10;
  public static readonly SPACE_12: number = 12;
  public static readonly SPACE_16: number = 16;
  public static readonly SPACE_24: number = 24;
  public static readonly SPACE_28: number = 28;
  public static readonly SPACE_32: number = 32;
  public static readonly SPACE_40: number = 40;
  public static readonly SPACE_48: number = 48;
  public static readonly SWIPER_DURATION: number = 3000;
  public static readonly PRELOAD_DURATION: number = 1200;
  public static readonly START_DELAY: number = 1000;
  public static readonly REMOVE_DURATION: number = 600;
  public static readonly ANIMATION_DELAY: number = 200;
  public static readonly ANIMATION_DURATION: number = 200;
  public static readonly TRANSITION_DURATION: number = 100;
  public static readonly BUTTON_TRANSITION_DURATION: number = 50;
  public static readonly FEEDBACK_BOTTOM_SM: number = 16;
  public static readonly SPAN_3: number = 3;
  public static readonly SPAN_4: number = 4;
  public static readonly SPAN_6: number = 6;
  public static readonly SPAN_8: number = 8;
  public static readonly SPAN_12: number = 12;
  public static readonly LANE_SM: number = 1;
  public static readonly LANE_MD: number = 2;
  public static readonly LANE_LG: number = 3;
  public static readonly LINEAR_GRADIENT_ANGLE: number = 180;
  public static readonly DYNAMIC_INSTALL_EVENT: string = 'DynamicInstallEvent';
  public static readonly BIND_SHEET_CLOSE_EVENT: string = 'BindSheetCloseEvent';
  public static readonly BIND_SHEET_OPEN_EVENT: string = 'BindSheetOpenEvent';
  public static readonly BIND_LOGOUT_EVENT: string = 'BindLogoutEvent';
  public static readonly BIND_MINE_LOGIN_EVENT: string = 'BindMineLoginEvent';
  public static readonly PROMISE_WAIT = (delay: number) => new Promise<void>((resolve) => setTimeout(resolve, delay));
  public static readonly BANNER_GEOMETRY: string = 'hmos_world_banner_geometry';
  public static readonly CODE_PREVIEW_GEOMETRY_ID: string = 'hmos_world_preview_geometry_id';
  public static readonly SHEET_WIDTH_XL: number = 800;
  public static readonly SHEET_HEIGHT_RATIO_XL: number = 0.9;
  // Window Property
  public static readonly WINDOW_RATIO: number = 0.9;
  public static readonly MIN_WINDOW_WIDTH: number = 1440;
  public static readonly MIN_WINDOW_HEIGHT: number = 940;
  // Default Image Size
  public static readonly DEFAULT_IMAGE_WIDTH: number = 1088;
  public static readonly DEFAULT_IMAGE_HEIGHT: number = 2250;
  // Unlimited Lines
  public static readonly UNLIMITED_LINES: number = 1000;
  // Break Word Offset
  public static readonly BREAK_WORD_OFFSET: number = 5;
  // Text Input Max Lines
  public static readonly TEXT_INPUT_MAX_LINES: number = 25;
  // Text Input Max Length
  public static readonly TEXT_INPUT_MAX_LENGTH: number = 500;
  // Feedback Sheet Type
  public static readonly SHEET_BOTTOM_ATTACHED: string = 'bottom_attached';
  public static readonly SHEET_CENTER_FLOATING: string = 'center_floating';
  // Feedback Sheet Height Type
  public static readonly SHEET_HEIGHT_LOW: string = 'low';
  public static readonly SHEET_HEIGHT_MID: string = 'mid';
  public static readonly SHEET_HEIGHT_HIGH: string = 'high';
  // Feedback Height Mapper
  public static SHEET_HEIGHT_MAPPER: Record<string, Record<string, number>> = {
    'bottom_attached': { 'low': 278, 'mid': 516, 'high': 748 },
    'center_floating': { 'low': 320, 'mid': 490, 'high': 490 },
  };
  // PC device type
  public static readonly PC_DEVICE_TYPE: string = '2in1';
  public static readonly TV_MINEPAGE_NAVBAR_WIDTH: string = '35%';
}