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

import { SegmentButtonTextItem } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import {
  BaseVM,
  BaseVMEvent,
  BreakpointTypeEnum,
  GlobalInfoModel,
  LoadingStatus,
  ObservedArray,
  PageContext,
  TopNavigationData,
} from '@ohos/common';
import {
  ColorPickerAttribute,
  ComponentDetailState,
  getEnumType,
  OpacityPickerAttribute,
  SelectComAttribute,
  SliderComAttribute,
  ToggleButtonAttribute,
  ToggleComAttribute,
} from './ComponentDetailState';
import type { AttributeData, ComponentDetailData, RecommendData } from '../model/ComponentDetailData';
import { ComponentDetailModel } from '../model/ComponentDetailModel';
import { Attribute, OriginAttribute } from './Attribute';
import { AttributeTypeEnum } from './AttributeTypeEnum';
import { CommonCodeGenerator } from './CommonCodeGenerator';
import { CommonAttributeFilter } from './CommonAttributeFilter';
import { CommonDescriptor } from './CommonDescriptor';
import type { ConfigInterface } from '../componentdetailview/ComponentDetailConfig';
import { ComponentDetailManager } from './ComponentDetailManager';

export class ComponentDetailPageVM extends BaseVM<ComponentDetailState> {
  public componentName: string;
  public codeGenerator: CommonCodeGenerator;
  public attributeFilter?: CommonAttributeFilter;
  public descriptor: CommonDescriptor;
  public originAttributes: OriginAttribute[] = [];
  public fullAttributes: ObservedArray<Attribute> = [];
  private detailPageModel = ComponentDetailModel.getInstance();
  private globalInfoModel: GlobalInfoModel = AppStorage.get('GlobalInfoModel')!;
  private detailData?: ComponentDetailData;

  constructor(componentName: string) {
    const componentDetailConfig: Record<string, ConfigInterface> = AppStorage.get('componentDetailConfig')!;
    super(new ComponentDetailState(componentDetailConfig[componentName].descriptor(), [], '', [], LoadingStatus.OFF,
      new TopNavigationData()));
    this.componentName = componentName;
    this.codeGenerator = componentDetailConfig[componentName].codeGenerate;
    this.attributeFilter = componentDetailConfig[componentName].attributeFilter;
    this.descriptor = componentDetailConfig[componentName].descriptor();
  }

  init(event: InitComponentEvent): Promise<void> {
    if (this.state.loadingStatus !== LoadingStatus.LOADING) {
      this.state.loadingStatus = LoadingStatus.LOADING;
      this.initTopNavigationData();
      this.state.code = '';
      this.state.recommends = [];
      this.state.attributes = [];
      if (this.detailData) {
        this.processAttribute(this.detailData.props);
        this.state.loadingStatus = LoadingStatus.SUCCESS;
        return Promise.resolve();
      }
      return this.detailPageModel.init(event.id).then((data: ComponentDetailData) => {
        this.detailData = data;
        this.processAttribute(data.props);
        this.state.loadingStatus = LoadingStatus.SUCCESS;
        ComponentDetailManager.getInstance().updateDetailViewModelMap(this.componentName, this);
      }).catch((_err: string) => {
        this.state.loadingStatus = LoadingStatus.FAILED;
      });
    }
    return Promise.resolve();
  }

  sendEvent(event: DetailPageEvent): Promise<string | void> | null {
    if (event instanceof InitComponentEvent) {
      return this.init(event);
    } else if ((event instanceof ChangeAttributeEvent) || (event instanceof ComPreviewChangeEvent)) {
      this.changeAttribute(event);
    } else if (event instanceof ComponentDetailEvent) {
      if (event.type === ComponentDetailEventType.INIT_RECOMMEND) {
        this.initRecommendList(this.detailData?.recommendList || []);
      } else if (event.type === ComponentDetailEventType.INIT_DESCRIPTOR) {
        this.initDescriptor();
      } else {
        return this.initWebCode();
      }
    } else if (event instanceof TopNavigationChangeEvent) {
      this.changeTopNavigationState(event);
    } else {
      this.changeAttributeEnable(event);
    }
    return null;
  }

  public pop(animated?: boolean) {
    const pageContext: PageContext =
      this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ? AppStorage.get('componentListPageContext')! :
        AppStorage.get('pageContext')!;
    pageContext.popPage(animated);
  }

  public jumpToCodePreview(code: string, preRebuild: () => void) {
    const pageContext: PageContext = this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ?
      AppStorage.get('componentListPageContext')! : AppStorage.get('pageContext')!;
    pageContext.openPage({
      routerName: 'CodePreviewView',
      param: {
        code: code,
        componentName: this.componentName,
        preFinishAnimation: preRebuild,
      } as CodeViewParams,
    }, false);
  }

  public jumpToPenKitView() {
    const pageContext: PageContext = this.globalInfoModel.currentBreakpoint === BreakpointTypeEnum.XL ?
      AppStorage.get('componentListPageContext')! : AppStorage.get('pageContext')!;
    pageContext.openPage({
      routerName: 'PenKitView',
    });
  }

  private changeAttribute(event: ChangeAttributeEvent | ComPreviewChangeEvent) {
    const index: number = this.originAttributes.findIndex((item) => item.name === event.attributeName);
    this.originAttributes[index].currentValue = event.attributeValue;
    this.fullAttributes[index].currentValue = event.attributeValue;
    this.state.code = this.codeGenerator.generate(this.originAttributes);
    if (this.attributeFilter) {
      this.attributeFilter.filter(this.fullAttributes);
    }
    this.state.attributes = this.fullAttributes.filter((attribute) => attribute.enable);
    // New instance.
    this.descriptor.convert(this.originAttributes);
    this.state.descriptor = this.descriptor;
  }

  private initWebCode(): Promise<void> {
    this.state.code = this.codeGenerator.generate(this.originAttributes);
    if (this.state.recommends.length === 0) {
      this.initRecommendList(this.detailData?.recommendList || []);
    }
    return Promise.resolve();
  }

  private initDescriptor(): void {
    this.state.descriptor.convert(this.originAttributes);
    if (this.attributeFilter) {
      this.attributeFilter.filter(this.fullAttributes);
    }
    this.state.attributes = this.fullAttributes.filter((attribute) => attribute.enable);
  }

  private changeAttributeEnable(event: AttributeChangeEnable): void {
    const name: string = event.attributeName;
    const enable: boolean = event.enable;
    const index = this.fullAttributes.findIndex(item => item.name === name);
    if (index !== -1) {
      this.fullAttributes[index].enable = enable;
      this.state.attributes = this.fullAttributes.filter((attribute) => attribute.enable);
    }
  }

  private initRecommendList(recommendList: RecommendData[]): void {
    const recommends: RecommendData[] = [];
    recommendList?.forEach((item) => {
      recommends.push({
        title: item.articleType === 1 ? $r('app.string.develop_practice') : $r('app.string.design_practice'),
        articleType: item.articleType,
        url: item.url,
      });
    });
    this.state.recommends = recommends;
  }

  private constructAttributeCom(originAttribute: OriginAttribute): Attribute {
    switch (originAttribute.type) {
      case AttributeTypeEnum.TOGGLE_BUTTON: {
        const attribute =
          new ToggleButtonAttribute(originAttribute.name, originAttribute.displayName, originAttribute.currentValue,
            originAttribute.type);
        originAttribute.values.map((item, index) => {
          attribute.selectOption[index] = { text: item } as SegmentButtonTextItem;
        });
        return attribute;
      }
      case AttributeTypeEnum.TOGGLE: {
        const attribute =
          new ToggleComAttribute(originAttribute.name, originAttribute.displayName, originAttribute.currentValue,
            originAttribute.type);
        return attribute;
      }
      case AttributeTypeEnum.SELECT: {
        const attribute =
          new SelectComAttribute(originAttribute.name, originAttribute.displayName, originAttribute.currentValue,
            originAttribute.type);
        attribute.selectOption = originAttribute.values.map((item) => {
          return { value: item } as SelectOption;
        });
        return attribute;
      }
      case AttributeTypeEnum.SLIDER: {
        const attribute =
          new SliderComAttribute(originAttribute.name, originAttribute.displayName, originAttribute.currentValue,
            originAttribute.type);
        attribute.leftRange = originAttribute.leftRange;
        attribute.rightRange = originAttribute.rightRange;
        attribute.step = originAttribute.step;
        return attribute;
      }
      case AttributeTypeEnum.COLOR: {
        const attribute =
          new ColorPickerAttribute(originAttribute.name, originAttribute.displayName, originAttribute.currentValue,
            originAttribute.type);
        return attribute;
      }
      default: {
        const attribute =
          new OpacityPickerAttribute(originAttribute.name, originAttribute.displayName, originAttribute.currentValue,
            originAttribute.type);
        attribute.leftRange = originAttribute.leftRange;
        attribute.rightRange = originAttribute.rightRange;
        attribute.step = originAttribute.step;
        return attribute;
      }
    }
  }

  private processAttribute(attributes: AttributeData[]) {
    let curValueArray: string[] = [];
    const systemColorMode: ConfigurationConstant.ColorMode = AppStorage.get('systemColorMode')!;
    const originAttributeList: OriginAttribute[] = [];
    const attributeList: ObservedArray<Attribute> = [];
    attributes.forEach((attribute: AttributeData) => {
      const originAttribute: OriginAttribute = new OriginAttribute();
      originAttribute.name = attribute.propertyName;
      originAttribute.displayName = attribute.propertyDesc;
      originAttribute.type = getEnumType(attribute);
      if (attribute.displayType === 'color') {
        curValueArray = attribute.defaultProperty.split(';');
        if (curValueArray.length === 1) {
          originAttribute.currentValue = curValueArray[0];
        } else {
          originAttribute.currentValue =
            systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ? curValueArray[0] : curValueArray[1];
        }
      } else {
        originAttribute.currentValue = attribute.defaultProperty;
      }

      if (attribute.displayType === 'enum') {
        originAttribute.values = JSON.parse(attribute.propertyValues);
      } else if (attribute.displayType === 'number' || attribute.displayType === 'opacity') {
        const propertyValues: Record<string, number> = JSON.parse(attribute.propertyValues);
        originAttribute.leftRange = propertyValues.left;
        originAttribute.rightRange = propertyValues.right;
        originAttribute.step = propertyValues.step;
      }
      originAttributeList.push(originAttribute);
      attributeList.push(this.constructAttributeCom(originAttribute));
    });
    this.fullAttributes = attributeList;
    this.state.attributes = attributeList;
    this.originAttributes = originAttributeList;
  }

  private initTopNavigationData() {
    this.state.topNavigationData = {
      title: `${this.componentName}`,
      titleColor: $r('sys.color.font_primary'),
      isFullScreen: true,
      isBlur: false,
      onBackClick: () => {
        this.pop();
      },
    };
  }

  private changeTopNavigationState(event: TopNavigationChangeEvent): void {
    this.state.topNavigationData = {
      title: this.state.topNavigationData.title,
      titleColor: this.state.topNavigationData.titleColor,
      isFullScreen: this.state.topNavigationData.isFullScreen,
      isBlur: event.isBlur,
      onBackClick: this.state.topNavigationData.onBackClick,
    };
  }
}


export enum ComponentDetailEventType {
  INIT_RECOMMEND = 'initRecommendEvent',
  INIT_DESCRIPTOR = 'initDescriptor',
  WEB_CODE_EVENT = 'webCodeEvent',
}

export class ComponentDetailEvent implements BaseVMEvent {
  public readonly type: ComponentDetailEventType;

  constructor(type: ComponentDetailEventType) {
    this.type = type;
  }
}

/**
 * Initial the data.
 */
export class InitComponentEvent implements BaseVMEvent {
  public readonly id: number;

  constructor(id: number) {
    this.id = id;
  }
}

/**
 * Update the attribute value in attribute-adjustment area.
 */
export class ChangeAttributeEvent implements BaseVMEvent {
  public readonly attributeName: string;
  public readonly attributeValue: string;

  constructor(attributeName: string, attributeValue: string) {
    this.attributeName = attributeName;
    this.attributeValue = attributeValue;
  }
}

/**
 * Update the attribute value in component-preview area.
 */
export class ComPreviewChangeEvent implements BaseVMEvent {
  public readonly attributeName: string;
  public readonly attributeValue: string;

  constructor(attributeName: string, attributeValue: string) {
    this.attributeName = attributeName;
    this.attributeValue = attributeValue;
  }
}

/**
 * Update the state value in Top Navigation area.
 */
export class TopNavigationChangeEvent implements BaseVMEvent {
  public readonly isBlur: boolean;

  constructor(isBlur: boolean) {
    this.isBlur = isBlur;
  }
}

/**
 * Change the active mode of the attribute.
 */
export class AttributeChangeEnable {
  public readonly attributeName: string;
  public readonly enable: boolean;

  constructor(attributeName: string, enable: boolean) {
    this.attributeName = attributeName;
    this.enable = enable;
  }
}

export interface CodeViewParams {
  code: string;
  componentName: string;
  preFinishAnimation: () => void;
}

export type DetailPageEvent = ComponentDetailEvent | InitComponentEvent | ChangeAttributeEvent | ComPreviewChangeEvent
  | AttributeChangeEnable | TopNavigationChangeEvent;