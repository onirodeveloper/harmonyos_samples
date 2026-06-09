/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

import { HdsNavDestination, ScrollEffectType } from '@hms.hds.hdsBaseComponent';
import { AboutItemCard } from '../component/AboutItemCard';
import { hdsMaterial } from '@kit.UIDesignKit';
import { CommonConstants } from '@ohos/common';

@Component
struct TvAboutView {
  @Builder
  contentBuilder() {
    Scroll(new Scroller()) {
      Column() {
        AboutItemCard()
        Column() {
          Text($r('app.string.copyright1'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_emphasize'))
            .fontSize($r('sys.float.Body_S'))
          Text($r('app.string.copyright2'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .margin({ bottom: $r('sys.float.padding_level12') })
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .align(Alignment.Top)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({
      top: $r('app.float.tv_mine_padding_top'),
      left: $r('app.float.tv_mine_padding_left_right'),
      right: $r('app.float.tv_mine_padding_left_right'),
    })
  }

  build() {
    HdsNavDestination() {
      this.contentBuilder()
    }
    .titleBar({
      avoidLayoutSafeArea: true,
      style: {
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE,
        },
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: hdsMaterial.getSystemMaterialTypes().length > 0 ? ScrollEffectType.GRADIENT_BLUR :
            ScrollEffectType.COMMON_BLUR,
        },
      },
      content: {
        title: { mainTitle: $r('app.string.tv_mine_about') },
      }
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
  }
}

@Builder
export function TVAboutViewBuilder() {
  TvAboutView()
}