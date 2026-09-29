public with sharing class SaludoService {

    public static String saludar(String nombre) {
        if (String.isBlank(nombre)) {
            return 'Hola';
        }

        return 'Hola, ' + nombre;
    }
}