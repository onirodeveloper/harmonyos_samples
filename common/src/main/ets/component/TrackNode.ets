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

import { TRACK_KEY, TrackEventType, TrackServiceData } from '../model/TrackModel';
import { TrackManager } from '../trackmanager/TrackManager';

@Component
export struct TrackNode {
  @BuilderParam closure: VoidCallback = this.defaultBuilder;
  actionName?: string;

  @Builder
  defaultBuilder() {
  }

  onDidBuild(): void {
    const uid: number = this.getUniqueId();
    const node: FrameNode | null = this.getUIContext().getFrameNodeByUniqueId(uid);
    if (node === null) {
      return;
    }
    const actualNode: FrameNode | null =
      TrackManager.getInstance().getChildFrameNode(node) || TrackManager.getInstance().getParentFrameNode(node);
    if (!actualNode) {
      return;
    }
    const trackServiceData: TrackServiceData | undefined = actualNode.getCustomProperty(TRACK_KEY) as TrackServiceData;
    if (!trackServiceData) {
      return;
    }
    node.commonEvent.setOnVisibleAreaApproximateChange(
      { ratios: [0.0, 1.0], expectedUpdateInterval: 10000 },
      (isExpanding: boolean, ratio) => {
        if (isExpanding && ratio >= 1.0) {
          const trackData: TrackServiceData = {
            eventType: TrackEventType.EXPOSURE,
            interactionType: trackServiceData.interactionType,
            interactionContent: trackServiceData.interactionContent,
          } as TrackServiceData;
          TrackManager.getInstance().reportData(trackData);
        }
      }
    )
  }

  build() {
    this.closure()
  }
}