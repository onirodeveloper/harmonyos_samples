import type { OriginAttribute } from './Attribute';

export interface CommonCodeGenerator {
  generate(attributes: OriginAttribute[]): string;
}