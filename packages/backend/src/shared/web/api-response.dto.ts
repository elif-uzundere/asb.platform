export class ApiResponseDto<T> {
  readonly success: boolean;
  readonly data?: T;
  readonly error?: { code: string; message: string };

  private constructor(success: boolean, data?: T, error?: { code: string; message: string }) {
    this.success = success;
    this.data = data;
    this.error = error;
  }

  static ok<T>(data: T): ApiResponseDto<T> {
    return new ApiResponseDto<T>(true, data);
  }

  static fail(code: string, message: string): ApiResponseDto<never> {
    return new ApiResponseDto<never>(false, undefined, { code, message });
  }
}
