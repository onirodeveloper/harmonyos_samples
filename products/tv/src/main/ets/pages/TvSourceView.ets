/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

import { CommonConstants, ConfigMapKey, Logger, ResourceUtil, StorageKey } from '@ohos/common';
import { HdsNavDestination, HdsNavDestinationTitleMode } from '@hms.hds.hdsBaseComponent';

const TAG: string = '[TVSourceView]';

@Component
struct TvSourceView {
  private sourceUrl: string = '';

  aboutToAppear(): void {
    const uiContext = AppStorage.get<UIContext>(StorageKey.UI_CONTEXT);
    const context = uiContext?.getHostContext();
    if (!uiContext || !context) {
      Logger.error(TAG, `Failed to jumpToBrowser. Cause uicontext or context is undefined.`);
      return;
    }
    this.sourceUrl = ResourceUtil.getRawFileStringByKey(context, ConfigMapKey.TV_SOURCE_CODE_URL) as string;
  }

  @Builder
  contentBuilder() {
    Column() {
      Text($r('app.string.view_sourcecode_see_details'))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .margin({ top: $r('sys.float.padding_level16') })
      Column() {
        QRCode(this.sourceUrl)
      }
      .backgroundColor(Color.White)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .padding($r('sys.float.padding_level4'))
      .margin({ top: $r('sys.float.padding_level12') })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.background_tertiary'))
  }

  build() {
    HdsNavDestination() {
      this.contentBuilder()
    }
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .hideBackButton(true)
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .titleBar({
      avoidLayoutSafeArea: true,
      content: {
        title: { mainTitle: $r('app.string.view_source') },
      },
    })
  }
}

@Builder
export function TvSourceViewBuilder() {
  TvSourceView()
}