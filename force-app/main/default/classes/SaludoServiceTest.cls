@IsTest
private class SaludoServiceTest {

    @IsTest
    static void testSaludarConNombre() {
        String resultado = SaludoService.saludar('Carlos');

        System.assertEquals(
            'Hola, Carlos',
            resultado
        );
    }

    @IsTest
    static void testSaludarSinNombre() {
        String resultado = SaludoService.saludar(null);

        System.assertEquals(
            'Hola',
            resultado
        );
    }
}