import { QRCodeComponent } from '../component/QRCodeComponent';
import { SourceCodeLinkPageParam } from '../viewmodel/SampleListViewModel';

@Component
export struct SourceCodeLinkPage {
  private webviewUrl: string = '';
  private title: string = '';

  handleOnReady(cxt: NavDestinationContext) {
    const params = cxt.pathInfo.param as SourceCodeLinkPageParam;
    this.webviewUrl = params.sourceCodeLink;
    this.title = params.title;
  }

  build() {
    NavDestination() {
      QRCodeComponent({ webviewUrl: this.webviewUrl, title: this.title})
    }
    .width(`100%`)
    .height(`100%`)
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => this.handleOnReady(ctx))
  }
}

@Builder
export function SourceCodeLinkPageBuilder() {
  SourceCodeLinkPage()
}