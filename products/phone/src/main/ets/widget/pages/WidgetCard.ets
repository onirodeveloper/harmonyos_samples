@Entry
@Component
struct WidgetCard {
  /*
   * The max lines.
   */
  readonly MAX_LINES: number = 1;
  /*
   * The action type.
   */
  readonly ACTION_TYPE: string = 'router';
  /*
   * The ability name.
   */
  readonly ABILITY_NAME: string = 'EntryAbility';
  /*
   * The width percentage setting.
   */
  readonly FULL_WIDTH_PERCENT: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly FULL_HEIGHT_PERCENT: string = '100%';

  build() {
    FormLink({
      action: this.ACTION_TYPE,
      abilityName: this.ABILITY_NAME,
    }) {
      Stack() {
        Image($r('app.media.ic_widget'))
          .width(this.FULL_WIDTH_PERCENT)
          .height(this.FULL_HEIGHT_PERCENT)
        Column() {
          Text($r('app.string.title_immersive'))
            .fontSize($r('sys.float.Subtitle_M'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Bold)
            .maxLines(this.MAX_LINES)
          Text($r('app.string.detail_immersive'))
            .fontSize($r('sys.float.Body_S'))
            .margin({ top: $r('sys.float.padding_level1') })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor($r('sys.color.font_on_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxLines(this.MAX_LINES)
        }
        .width(this.FULL_WIDTH_PERCENT)
        .height(this.FULL_HEIGHT_PERCENT)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .padding($r('sys.float.padding_level6'))
      }
      .width(this.FULL_WIDTH_PERCENT)
      .height(this.FULL_HEIGHT_PERCENT)
    }
  }
}