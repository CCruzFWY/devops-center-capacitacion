public with sharing class SaludoService {

    public static String saludar(String nombre) {
        if (String.isBlank(nombre)) {
            System.debug('Hey');
            return 'Hola';
        }

        return 'Hola, ' + nombre;
    }
}