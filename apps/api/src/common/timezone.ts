import { registerDecorator, type ValidationOptions } from 'class-validator';

export const TIMEZONE_VALIDATION_MESSAGE = 'timezone must be a valid IANA time zone';

export function isValidTimeZone(timeZone: string): boolean {
  try {
    new Intl.DateTimeFormat('en-US', { timeZone }).format();
    return true;
  } catch {
    return false;
  }
}

export function IsValidTimeZone(validationOptions?: ValidationOptions): PropertyDecorator {
  return (target: object, propertyName: string | symbol) => {
    registerDecorator({
      name: 'isValidTimeZone',
      target: target.constructor,
      propertyName: propertyName as string,
      options: {
        message: TIMEZONE_VALIDATION_MESSAGE,
        ...validationOptions,
      },
      validator: {
        validate(value: unknown): boolean {
          return typeof value === 'string' && isValidTimeZone(value);
        },
      },
    });
  };
}
