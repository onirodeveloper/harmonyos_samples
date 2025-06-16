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

import { DetailPageConstant } from '../../../constant/DetailPageConstant';
import type { OriginAttribute } from '../../../viewmodel/Attribute';
import { CommonCodeGenerator } from '../../../viewmodel/CommonCodeGenerator';
import { edgeEffectMapData, LanesStyle, listDirectionMapData } from '../entity/ListAttributeMapping';

export class ListCodeGenerator implements CommonCodeGenerator {
  private listDirection: string = listDirectionMapData.get('Default')!.code;
  private lanes: LanesStyle = {
    value: 1,
    gutter: 0,
  };
  private edgeEffect: string = edgeEffectMapData.get('Default')!.code;
  private sticky: boolean = true;
  private stickyName: string = 'StickyStyle.Header';

  public generate(attributes: OriginAttribute[]): string {
    let height: string = '';
    let aspectRatio: number = DetailPageConstant.ASPECT_RATIO_SQUARE;
    attributes.forEach((attribute) => {
      switch (attribute.name) {
        case 'listDirection':
          this.listDirection = listDirectionMapData.get(attribute.currentValue)?.code ?? this.listDirection;
          break;
        case 'lanesNum':
          this.lanes = {
            value: Number(attribute.currentValue),
            gutter: this.lanes.gutter
          };
          if (this.lanes.value >= DetailPageConstant.LIST_LANES_THRESHOLD) {
            height = '64vp';
            aspectRatio = DetailPageConstant.ASPECT_RATIO_SQUARE;
          } else {
            height = '92vp';
            aspectRatio = DetailPageConstant.ASPECT_RATIO_INVALID;
          }
          break;
        case 'gutter':
          this.lanes = {
            value: this.lanes.value,
            gutter: Number(attribute.currentValue ?? 0)
          };
          break;
        case 'edgeEffect':
          this.edgeEffect = edgeEffectMapData.get(attribute.currentValue)?.code ?? this.edgeEffect;
          break;
        case 'sticky':
          this.sticky = JSON.parse(attribute.currentValue);
          this.sticky && (this.stickyName = 'StickyStyle.Header');
          !this.sticky && (this.stickyName = 'StickyStyle.None');
          break;
        default:
          break;
      }
    });
    const codeOne: string = `
    [
      {
        title: 'ONE',
        projects: ['item 1', 'item 2', 'item 3', 'item 4']
      },
      {
        title: 'TWO',
        projects: ['item 5', 'item 6', 'item 7', 'item 8']
      },
      {
        title: 'THREE',
        projects: ['item 9', 'item 10', 'item 11', 'item 12']
      },
      {
        title: 'FOUR',
        projects: ['item 13', 'item 14', 'item 15', 'item 16']
      }
    ]`;
    return `interface TimeTable {
  title: string;
  projects: string[];
}

@Component
struct ListComponent {
  @State listData: TimeTable[] = ${codeOne};

  @Builder
  itemHead(text: string) {
    Text(text)
      .textAlign(TextAlign.Center)
      .fontSize($r('sys.float.Body_L'))
      .backgroundColor($r('sys.color.comp_background_emphasize'))
      .fontColor($r('sys.color.font_on_primary'))
      .width('100%')
      .height(32)
      .margin({ bottom: $r('sys.float.padding_level4') })
  }

  build() {
    Column() {
      List({ space: 8 }) {
        ForEach(this.listData, (item: TimeTable) => {
          ListItemGroup({ header: this.itemHead(item.title) }) {
            ForEach(item.projects, (project: string) => {
              ListItem() {
                Column() {
                  Text(project)
                    .fontSize($r('sys.float.Body_L'))
                    .fontColor($r('sys.color.font_emphasize'))
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .height('100%')
                .borderRadius($r('sys.float.corner_radius_level4'))
                .border({ width: 1.5, color: $r('sys.color.comp_background_emphasize') })
                .justifyContent(FlexAlign.Center)
              }
              .width('100%')
              .height('${height}')
              .aspectRatio(${aspectRatio})
            }, (item: string) => item)
          }
        }, (item: TimeTable, _index: number) => item.title.toString())
      }
      .width('100%')
      .height('100%')
      .sticky(${this.stickyName})
      .scrollBar(BarState.Off)
      .lanes(${this.lanes.value}, ${this.lanes.gutter})
      .listDirection(${this.listDirection})
      .edgeEffect(${this.edgeEffect})
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .clip(true)
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}`;
  }
}