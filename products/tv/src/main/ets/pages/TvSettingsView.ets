/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

import { CommonConstants, HmosListItem, PageContext, PageEnum, StorageKey } from '@ohos/common';
import { HdsNavDestination, ScrollEffectType } from '@hms.hds.hdsBaseComponent';
import { hdsMaterial } from '@kit.UIDesignKit';

@Component
struct TvSettingsView {

  @StorageLink(StorageKey.MINE_PAGE_CONTEXT) minePageContext: PageContext =
    AppStorage.get<PageContext>(StorageKey.MINE_PAGE_CONTEXT) ?? new PageContext();

  @Builder
  contentBuilder() {
    Scroll(new Scroller()) {
      Column({ space: 16 }) {
        HmosListItem({
          title: $r('app.string.tv_mine_about'),
          handleClickAction: () => {
            this.minePageContext.openPage({
              routerName: PageEnum.TV_ABOUT_VIEW,
            }, true);
          }
        })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
    .align(Alignment.Top)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({
      top: 100,
      left: 50,
      right: 50,
    })
    .backgroundColor($r('sys.color.comp_background_secondary'))
  }

  build() {
    HdsNavDestination() {
      this.contentBuilder()
    }
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
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
        title: { mainTitle: $r('app.string.tv_mine_setting') },
      },
    })
  }
}

@Builder
export function TvSettingsViewBuilder() {
  TvSettingsView()
}