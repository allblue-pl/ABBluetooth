import Foundation

public enum TABBluetooth: String, CaseIterable {
    case errors_CannotFindPrinter = "Nie znaleziono drukarki."
    case errors_CannotFindPrintingService = "Nie znaleziono usługi drukowania"
    case errors_CannotFindSupportedProtocol = "Nie znaleziono obsługiwanego protokołu bluetooth."
    case errors_CannotGenerateImage = "Nie udało się wygenerować wydruku."
    case errors_NoBluetoothPermission = "Brak pozwolenia na korzystanie z bluetooth. Żeby skorzystać z funkcji Bluetooth musisz zezwolić na jego wykorzystanie w ustawieniach telefonu."
    case errors_UnknownError = "Nieznany błąd"
}
