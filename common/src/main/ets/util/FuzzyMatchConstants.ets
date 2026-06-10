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

/**
 * For match rate threshold when to-be-matched strings' length shorter than 14 chars.
 * Indicate that how many chars must matched at least so that they can be count as matched.
 *   E.g. 1 letter in a 100 words sentence got matched is meaningless,
 *     we expect a 6-chars-long word have at least 4 chars matching with each other.
 */

export const WHEN_LENGTH_SHORTER_THAN_FOURTEEN = [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6, 7, 7, 7];