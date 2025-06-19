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

import type { GlobalInfoModel } from '@ohos/common';
import { BreakpointType, ColumnEnum, CommonConstants, VideoComponent } from '@ohos/common';
import { MediaTypeEnum } from '@ohos/commonbusiness';
import { SampleDetailData } from '../viewmodel/SampleDetailState';
import { SampleCard } from './SampleCard';

@Component
export struct SampleComponent {
  @StorageProp('GlobalInfoModel') globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  @ObjectLink singleSampleData: SampleDetailData;
  @Prop @Require sampleIndex: number;
  @Prop showIndicator: boolean = false;

  build() {
    Column() {
      Column() {
        if (this.singleSampleData.mediaType === MediaTypeEnum.IMAGE) {
          Image($rawfile(this.singleSampleData.mediaUrl))
            .draggable(false)
            .alt($r('app.media.img_placeholder'))
            .objectFit(ImageFit.Contain)
            .layoutWeight(1)
        } else {
          VideoComponent({
            mediaSrc: this.singleSampleData.mediaUrl,
            autoPlay: true,
            loopPlay: true,
            clickPause: false,
            startVisibleRatio: 0.5,
          })
        }
      }
      .layoutWeight(1)

      GridRow({
        columns: { sm: ColumnEnum.SM, md: ColumnEnum.MD, lg: ColumnEnum.LG },
        gutter: {
          x: {
            sm: $r('sys.float.padding_level6'),
            md: $r('sys.float.padding_level6'),
            lg: $r('sys.float.padding_level8'),
          },
        },
      }) {
        GridCol({
          span: { sm: CommonConstants.SPAN_4, md: CommonConstants.SPAN_6, lg: CommonConstants.SPAN_8 },
          offset: { sm: 0, md: 1, lg: 2 },
        }) {
          SampleCard({ sampleCard: this.singleSampleData.sampleCard, sampleIndex: this.sampleIndex, })
        }
      }
      .margin({
        bottom: this.showIndicator ? $r('sys.float.padding_level16') : $r('sys.float.padding_level8'),
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .height('100%')
    .width('100%')
    .padding({
      top: $r('sys.float.padding_level4'),
      left: new BreakpointType({
        sm: $r('sys.float.padding_level8'),
        md: $r('sys.float.padding_level12'),
        lg: $r('sys.float.padding_level16'),
      }).getValue(this.globalInfoModel.currentBreakpoint),
      right: new BreakpointType({
        sm: $r('sys.float.padding_level8'),
        md: $r('sys.float.padding_level12'),
        lg: $r('sys.float.padding_level16'),
      }).getValue(this.globalInfoModel.currentBreakpoint),
    })
  }
}