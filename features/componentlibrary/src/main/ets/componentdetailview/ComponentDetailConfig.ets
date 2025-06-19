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

import { ActionSheetBuilder } from './actionsheetview/component/ActionSheetBuilder'
import { ActionSheetCodeGenerator } from './actionsheetview/viewmodel/ActionSheetCodeGenerator'
import { ActionSheetDescriptor } from './actionsheetview/viewmodel/ActionSheetDescriptor'
import { AICaptionBuilder } from './aicaption/component/AICaptionBuilder'
import { AICaptionCodeGenerator } from './aicaption/viewmodel/AICaptionCodeGenerator'
import { AlertDialogBuilder } from './alertdialogview/component/AlertDialogBuilder'
import { AlertDialogCodeGenerator } from './alertdialogview/viewmodel/AlertDialogCodeGenerator'
import { AlertDialogDescriptor } from './alertdialogview/viewmodel/AlertDialogDescriptor'
import { AppLinkingBuilder } from './applinking/component/AppLinkingBuilder'
import { AppLinkingCodeGenerator } from './applinking/viewmodel/AppLinkingCodeGenerator'
import { AppLinkingDescriptor } from './applinking/viewmodel/AppLinkingDescriptor'
import { ButtonBuilder } from './buttonview/component/ButtonBuilder'
import { ButtonCodeGenerator } from './buttonview/viewmodel/ButtonCodeGenerator'
import { ButtonDescriptor } from './buttonview/viewmodel/ButtonDescriptor'
import { ColumnBuilder } from './columnview/component/ColumnBuilder'
import { ColumnCodeGenerator } from './columnview/viewmodel/ColumnCodeGenerator'
import { ColumnDescriptor } from './columnview/viewmodel/ColumnDescriptor'
import { CommonCodeGenerator } from '../viewmodel/CommonCodeGenerator'
import { CommonDescriptor } from '../viewmodel/CommonDescriptor'
import { DescriptorWrapper } from '../viewmodel/DescriptorWrapper'
import { CustomDialogBuilder } from './customdialog/component/CustomDialogBuilder'
import { CustomDialogCodeGenerator } from './customdialog/viewmodel/CustomDialogCodeGenerator'
import { CustomDialogDescriptor } from './customdialog/viewmodel/CustomDialogDescriptor'
import { DocumentViewPickerBuilder } from './documentviewpicker/component/DocumentViewPickerBuilder'
import { DocumentViewPickerCodeGenerator } from './documentviewpicker/viewmodel/DocumentViewPickerCodeGenerator'
import { FlexBuilder } from './flex/component/FlexBuilder'
import { FlexCodeGenerator } from './flex/viewmodel/FlexCodeGenerator'
import { FlexDescriptor } from './flex/viewmodel/FlexDescriptor'
import { GridBuilder } from './grid/component/GridBuilder'
import { GridCodeGenerator } from './grid/viewmodel/GridCodeGenerator'
import { GridDescriptor } from './grid/viewmodel/GridDescriptor'
import { ImageBuilder } from './Image/component/ImageBuilder'
import { ImageCodeGenerator } from './Image/viewmodel/ImageCodeGenerator'
import { ImageDescriptor } from './Image/viewmodel/ImageDescriptor'
import { AIImageBuilder } from './imageaianalyzer/component/AIImageBuilder'
import { AIImageCodeGenerator } from './imageaianalyzer/viewmodel/AIImageCodeGenerator'
import { ListBuilder } from './list/component/ListBuilder'
import { ListCodeGenerator } from './list/viewmodel/ListCodeGenerator'
import { ListDescriptor } from './list/viewmodel/ListDescriptor'
import { PenKitBuilder } from './penkit/component/PenKitBuilder'
import { PenKitCodeGenerator } from './penkit/viewmodel/PenKitCodeGenerator'
import { PhotoViewPickerBuilder } from './photopicker/component/PhotoViewPickerBuilder'
import { PhotoViewPickerCodeGenerator } from './photopicker/viewmodel/PhotoViewPickerCodeGenerator'
import { CalendarPickerBuilder } from './picker/calendarPicker/component/CalendarPickerBuilder'
import { CalendarPickerCodeGenerator } from './picker/calendarPicker/viewmodel/CalendarPickerCodeGenerator'
import { CalendarPickerDescriptor } from './picker/calendarPicker/viewmodel/CalendarPickerDescriptor'
import { CameraPickerBuilder } from './picker/camerapicker/component/CameraPickerBuilder'
import { CameraPickerCodeGenerator } from './picker/camerapicker/viewmodel/CameraPickerCodeGenerator'
import { DatePickerBuilder } from './picker/datepicker/component/DatePickerBuilder'
import { DatePickerCodeGenerator } from './picker/datepicker/viewmodel/DatePickerCodeGenerator'
import { DatePickerDescriptor } from './picker/datepicker/viewmodel/DatePickerDescriptor'
import { PopupBuilder } from './popup/component/PopupBuilder'
import { PopupCodeGenerator } from './popup/viewmodel/PopupCodeGenerator'
import { PopupDescriptor } from './popup/viewmodel/PopupDescriptor'
import { ProgressBuilder } from './progress/component/ProgressBuilder'
import { ProgressCodeGenerator } from './progress/viewmodel/ProgressCodeGenerator'
import { ProgressDescriptor } from './progress/viewmodel/ProgressDescriptor'
import { RatingBuilder } from './rating/component/RatingBuilder'
import { RatingCodeGenerator } from './rating/viewmodel/RatingCodeGenerator'
import { RatingDescriptor } from './rating/viewmodel/RatingDescriptor'
import { RowBuilder } from './rowview/component/RowBuilder'
import { RowCodeGenerator } from './rowview/viewmodel/RowCodeGenerator'
import { RowDescriptor } from './rowview/viewmodel/RowDescriptor'
import { StackBuilder } from './stackview/component/StackBuilder'
import { StackCodeGenerator } from './stackview/viewmodel/StackCodeGenerator'
import { StackDescriptor } from './stackview/viewmodel/StackDescriptor'
import { StyleTextBuilder } from './styletext/component/StyleTextBuilder'
import { StyleTextCodeGenerator } from './styletext/viewmodel/StyleTextCodeGenerator'
import { StyleTextDescriptor } from './styletext/viewmodel/StyleTextDescriptor'
import { SwiperBuilder } from './swiperView/component/SwiperBuilder'
import { SwiperCodeGenerator } from './swiperView/viewmodel/SwiperCodeGenerator'
import { SwiperDescriptor } from './swiperView/viewmodel/SwiperDescriptor'
import { TabBuilder } from './tabview/component/TabBuilder'
import { TabCodeGenerator } from './tabview/viewmodel/TabCodeGenerator'
import { TabDescriptor } from './tabview/viewmodel/TabDescriptor'
import { TextAreaBuilder } from './textarea/component/TextAreaBuilder'
import { TextAreaCodeGenerator } from './textarea/viewmodel/TextAreaCodeGenerator'
import { TextAreaDescriptor } from './textarea/viewmodel/TextAreaDescriptor'
import { TextInputBuilder } from './textinput/component/TextInputBuilder'
import { TextInputCodeGenerator } from './textinput/viewmodel/TextInputCodeGenerator'
import { TextInputDescriptor } from './textinput/viewmodel/TextInputDescriptor'
import { TextPickerDialogBuilder } from './textpickerdialogview/component/TextPickerDialogBuilder'
import { TextPickerDialogCodeGenerator } from './textpickerdialogview/viewmodel/TextPickerDialogCodeGenerator'
import { TextPickerDialogDescriptor } from './textpickerdialogview/viewmodel/TextPickerDialogDescriptor'
import { TextToSpeechBuilder } from './texttospeech/component/TextToSpeechBuilder'
import { TextToSpeechCodeGenerator } from './texttospeech/viewmodel/TextToSpeechCodeGenerator'
import { TextToSpeechDescriptor } from './texttospeech/viewmodel/TextToSpeechDescriptor'
import { TextBuilder } from './textview/component/TextBuilder'
import { TextCodeGenerator } from './textview/viewmodel/TextCodeGenerator'
import { TextDescriptor } from './textview/viewmodel/TextDescriptor'
import { ToggleBuilder } from './toggleview/component/ToggleBuilder'
import { ToggleCodeGenerator } from './toggleview/viewmodel/ToggleCodeGenerator'
import { ToggleDescriptor } from './toggleview/viewmodel/ToggleDescriptor'
import { WaterFlowBuilder } from './waterflow/component/WaterFlowBuilder'
import { WaterFlowCodeGenerator } from './waterflow/viewmodel/WaterFlowCodeGenerator'
import { WaterFlowDescriptor } from './waterflow/viewmodel/WaterFlowDescriptor'
import { CommonAttributeFilter } from '../viewmodel/CommonAttributeFilter'
import { StackAttributeFilter } from './stackview/viewmodel/StackAttributeFilter'
import { RatingAttributeFilter } from './rating/viewmodel/RatingAttributeFilter'
import { ButtonAttributeFilter } from './buttonview/viewmodel/ButtonAttributeFilter'
import { WaterFlowAttributeFilter } from './waterflow/viewmodel/WaterflowAttributeFilter'
import { FlexAttributeFilter } from './flex/viewmodel/FlexAttributeFilter'
import { ProgressAttributeFilter } from './progress/viewmodel/ProgressAttributeFilter'
import { ToggleAttributeFilter } from './toggleview/viewmodel/ToggleAttributeFilter'
import { ColumnAttributeFilter } from './columnview/viewmodel/ColumnAttributeFilter'
import { RowAttributeFilter } from './rowview/viewmodel/RowAttributeFilter'
import { CameraPickerDescriptor } from './picker/camerapicker/viewmodel/CameraPickerDescriptor'

export const componentDetailConfig: Record<string, ConfigInterface> = {
  'Button': {
    previewComponentBuilder: wrapBuilder(ButtonBuilder),
    descriptor: () => new ButtonDescriptor(),
    codeGenerate: new ButtonCodeGenerator(),
    attributeFilter: new ButtonAttributeFilter(),
  },
  'Column': {
    previewComponentBuilder: wrapBuilder(ColumnBuilder),
    descriptor: () => new ColumnDescriptor(),
    codeGenerate: new ColumnCodeGenerator(),
    attributeFilter: new ColumnAttributeFilter(),
  },
  'Row': {
    previewComponentBuilder: wrapBuilder(RowBuilder),
    descriptor: () => new RowDescriptor(),
    codeGenerate: new RowCodeGenerator(),
    attributeFilter: new RowAttributeFilter(),
  },
  'Stack': {
    previewComponentBuilder: wrapBuilder(StackBuilder),
    descriptor: () => new StackDescriptor(),
    codeGenerate: new StackCodeGenerator(),
    attributeFilter: new StackAttributeFilter(),
  },
  'Grid': {
    previewComponentBuilder: wrapBuilder(GridBuilder),
    descriptor: () => new GridDescriptor(),
    codeGenerate: new GridCodeGenerator(),
  },
  'Progress': {
    previewComponentBuilder: wrapBuilder(ProgressBuilder),
    descriptor: () => new ProgressDescriptor(),
    codeGenerate: new ProgressCodeGenerator(),
    attributeFilter: new ProgressAttributeFilter(),
  },
  'Text': {
    previewComponentBuilder: wrapBuilder(TextBuilder),
    descriptor: () => new TextDescriptor(),
    codeGenerate: new TextCodeGenerator(),
  },
  'TextArea': {
    previewComponentBuilder: wrapBuilder(TextAreaBuilder),
    descriptor: () => new TextAreaDescriptor(),
    codeGenerate: new TextAreaCodeGenerator(),
  },
  'TextInput': {
    previewComponentBuilder: wrapBuilder(TextInputBuilder),
    descriptor: () => new TextInputDescriptor(),
    codeGenerate: new TextInputCodeGenerator(),
  },
  'TextStyle': {
    previewComponentBuilder: wrapBuilder(StyleTextBuilder),
    descriptor: () => new StyleTextDescriptor(),
    codeGenerate: new StyleTextCodeGenerator(),
  },
  'Image': {
    previewComponentBuilder: wrapBuilder(ImageBuilder),
    descriptor: () => new ImageDescriptor(),
    codeGenerate: new ImageCodeGenerator()
  },
  'Rating': {
    previewComponentBuilder: wrapBuilder(RatingBuilder),
    descriptor: () => new RatingDescriptor(),
    codeGenerate: new RatingCodeGenerator(),
    attributeFilter: new RatingAttributeFilter(),
  },
  'Toggle': {
    previewComponentBuilder: wrapBuilder(ToggleBuilder),
    descriptor: () => new ToggleDescriptor(),
    codeGenerate: new ToggleCodeGenerator(),
    attributeFilter: new ToggleAttributeFilter(),
  },
  'TextToSpeech': {
    previewComponentBuilder: wrapBuilder(TextToSpeechBuilder),
    descriptor: () => new TextToSpeechDescriptor(),
    codeGenerate: new TextToSpeechCodeGenerator(),
  },
  'AICaptionComponent': {
    previewComponentBuilder: wrapBuilder(AICaptionBuilder),
    descriptor: () => new CommonDescriptor(),
    codeGenerate: new AICaptionCodeGenerator(),
  },
  'Flex': {
    previewComponentBuilder: wrapBuilder(FlexBuilder),
    descriptor: () => new FlexDescriptor(),
    codeGenerate: new FlexCodeGenerator(),
    attributeFilter: new FlexAttributeFilter(),
  },
  'List': {
    previewComponentBuilder: wrapBuilder(ListBuilder),
    descriptor: () => new ListDescriptor(),
    codeGenerate: new ListCodeGenerator(),
  },
  'WaterFlow': {
    previewComponentBuilder: wrapBuilder(WaterFlowBuilder),
    descriptor: () => new WaterFlowDescriptor(),
    codeGenerate: new WaterFlowCodeGenerator(),
    attributeFilter: new WaterFlowAttributeFilter(),
  },
  'Tabs': {
    previewComponentBuilder: wrapBuilder(TabBuilder),
    descriptor: () => new TabDescriptor(),
    codeGenerate: new TabCodeGenerator(),
  },
  'Swiper': {
    previewComponentBuilder: wrapBuilder(SwiperBuilder),
    descriptor: () => new SwiperDescriptor(),
    codeGenerate: new SwiperCodeGenerator(),
  },
  'Penkit': {
    previewComponentBuilder: wrapBuilder(PenKitBuilder),
    descriptor: () => new CommonDescriptor(),
    codeGenerate: new PenKitCodeGenerator(),
  },
  'AlertDialog': {
    previewComponentBuilder: wrapBuilder(AlertDialogBuilder),
    descriptor: () => new AlertDialogDescriptor(),
    codeGenerate: new AlertDialogCodeGenerator(),
  },
  'TextPickerDialog': {
    previewComponentBuilder: wrapBuilder(TextPickerDialogBuilder),
    descriptor: () => new TextPickerDialogDescriptor(),
    codeGenerate: new TextPickerDialogCodeGenerator(),
  },
  'CustomDialog': {
    previewComponentBuilder: wrapBuilder(CustomDialogBuilder),
    descriptor: () => new CustomDialogDescriptor(),
    codeGenerate: new CustomDialogCodeGenerator(),
  },
  'ActionSheet': {
    previewComponentBuilder: wrapBuilder(ActionSheetBuilder),
    descriptor: () => new ActionSheetDescriptor(),
    codeGenerate: new ActionSheetCodeGenerator(),
  },
  'Popup': {
    previewComponentBuilder: wrapBuilder(PopupBuilder),
    descriptor: () => new PopupDescriptor(),
    codeGenerate: new PopupCodeGenerator(),
  },
  'CalendarPicker': {
    previewComponentBuilder: wrapBuilder(CalendarPickerBuilder),
    descriptor: () => new CalendarPickerDescriptor(),
    codeGenerate: new CalendarPickerCodeGenerator(),
  },
  'DatePicker': {
    previewComponentBuilder: wrapBuilder(DatePickerBuilder),
    descriptor: () => new DatePickerDescriptor(),
    codeGenerate: new DatePickerCodeGenerator(),
  },
  'DocumentViewPicker': {
    previewComponentBuilder: wrapBuilder(DocumentViewPickerBuilder),
    descriptor: () => new CommonDescriptor(),
    codeGenerate: new DocumentViewPickerCodeGenerator(),
  },
  'AppLinking': {
    previewComponentBuilder: wrapBuilder(AppLinkingBuilder),
    descriptor: () => new AppLinkingDescriptor(),
    codeGenerate: new AppLinkingCodeGenerator(),
  },
  'CameraPicker': {
    previewComponentBuilder: wrapBuilder(CameraPickerBuilder),
    descriptor: () => new CameraPickerDescriptor(),
    codeGenerate: new CameraPickerCodeGenerator(),
  },
  'PhotoViewPicker': {
    previewComponentBuilder: wrapBuilder(PhotoViewPickerBuilder),
    descriptor: () => new CommonDescriptor(),
    codeGenerate: new PhotoViewPickerCodeGenerator(),
  },
  'AI Matting': {
    previewComponentBuilder: wrapBuilder(AIImageBuilder),
    descriptor: () => new CommonDescriptor(),
    codeGenerate: new AIImageCodeGenerator(),
  },
}

export interface ConfigInterface {
  previewComponentBuilder: WrappedBuilder<[DescriptorWrapper]>;
  descriptor: () => CommonDescriptor;
  codeGenerate: CommonCodeGenerator;
  attributeFilter?: CommonAttributeFilter;
}