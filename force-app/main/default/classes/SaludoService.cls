public with sharing class SaludoService {
    public static String saludar(String nombre) {
        System.debug('Test');
        return 'Bienvenido, ' + nombre;
    }
}