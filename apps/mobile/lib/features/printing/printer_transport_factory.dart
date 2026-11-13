import 'android_printer_transport.dart';
import 'lan_printer_transport.dart';
import 'printer_models.dart';
import 'printer_transport.dart';
import 'usb_printer_transport.dart';

/// Creates the transport implementation selected by the saved printer config.
/// The adapter only talks to [PrinterTransport], so tests replace this factory
/// without changing receipt layout or queue state handling.
abstract interface class PrinterTransportFactory {
  PrinterTransport create(PrinterTransportType type);
}

class PlatformPrinterTransportFactory implements PrinterTransportFactory {
  const PlatformPrinterTransportFactory();

  @override
  PrinterTransport create(PrinterTransportType type) {
    return switch (type) {
      PrinterTransportType.bluetoothClassic =>
        AndroidBluetoothPrinterTransport(),
      PrinterTransportType.network => LanPrinterTransport(),
      PrinterTransportType.usb => UsbPrinterTransport(),
    };
  }
}
