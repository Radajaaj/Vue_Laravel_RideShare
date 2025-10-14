<template>

    <div class="pt-16">
        <h1 class="text-3xl font-semibold mb-4">Insira seu telefone</h1>
        <form v-if="!waitingOnVerification" action="#" @submit.prevent="handleLogin">
            <div class="overflow-hidden shadow sm:rounded-md max-w-sm mx-auto text-left">
                <div class="bg-white px-4 py-5 sm:p-6">
                <div>
            <input type="text" v-maska="'## (##) #####-#####'" v-model="credentials.phone" name="phone" id="phone" placeholder="+55 (99) 99999-9999"
                         class="mt-1 block w-full px-3 py-2 rounded-md border border-gray-300 shadow-sm placeholder-gray-400 focus:border-blue-500 focus:ring-blue-500 sm:text-sm"/>
                    <p v-if="errors.phone" class="text-sm text-red-600 mt-2">{{ errors.phone }}</p>
                            <p class="text-xs text-gray-500 mt-2">O número será enviado no formato internacional (E.164), por exemplo +559912345678.</p>
                </div>
                </div>
                <div class="bg-gray-50 px-4 py-3 text-right sm:px-6">
                    <button type="submit" @submit.prevent="handleLogin"
                            class="inline-flex justify-center rounded-md border border-transparent bg-blue-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                        Enviar
                    </button>
                </div>
            </div>
        </form>

        <form v-else action="#" @submit.prevent="handleVerification">
            <div class="overflow-hidden shadow sm:rounded-md max-w-sm mx-auto text-left">
                <div class="bg-white px-4 py-5 sm:p-6">
                <div>
            <input type="text" v-maska="'######'" v-model="credentials.login_code" name="login_code" id="login_code" placeholder="123456"
                         class="mt-1 block w-full px-3 py-2 rounded-md border border-gray-300 shadow-sm placeholder-gray-400 focus:border-blue-500 focus:ring-blue-500 sm:text-sm"/>
                    <p v-if="errors.login_code" class="text-sm text-red-600 mt-2">{{ errors.login_code }}</p>
                </div>
                </div>
                <div class="bg-gray-50 px-4 py-3 text-right sm:px-6">
                    <button type="submit" @submit.prevent="handleVerification"
                            class="inline-flex justify-center rounded-md border border-transparent bg-blue-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                        Verificar
                    </button>
                </div>
                    <div v-if="errors.general" class="max-w-sm mx-auto mt-3 text-center text-red-600">{{ errors.general }}</div>
            </div>
        </form>

        <!-- Debug panel -->
        <div class="max-w-sm mx-auto mt-6 p-4 bg-gray-50 rounded border">
            <h3 class="font-semibold mb-2">Debug</h3>
            <div class="text-xs text-gray-600 mb-2">Payload sent:</div>
            <pre class="text-sm bg-white p-2 rounded" v-if="payloadSent">{{ JSON.stringify(payloadSent, null, 2) }}</pre>
            <div class="text-xs text-gray-600 mt-3 mb-2">Server response:</div>
            <pre class="text-sm bg-white p-2 rounded" v-if="serverResponse">{{ JSON.stringify(serverResponse, null, 2) }}</pre>
        </div>


    </div>

</template>



<script setup>
    import { onMounted, reactive, ref } from 'vue';
    import { useRouter } from 'vue-router';
    import axios from 'axios';

    const router = useRouter();

    const credentials = reactive({
        phone: null
    });
    // include login_code here so it's reactive from the start
    credentials.login_code = null;


    const waitingOnVerification = ref(false);

    onMounted(() => {                           //Verifica se já tem um auth token armazenado (user já logou)
        if (localStorage.getItem('token')){
            router.push({
                name: 'landing'                   // Redireciona ele pro coiso de users logados
            })
        }
    })



    // UI validation/errors from server
    const errors = reactive({
        phone: null,
        general: null
    });
    errors.login_code = null;

    // Debug helpers to inspect what we send and what the server replies
    const payloadSent = ref(null);
    const serverResponse = ref(null);

    const handleLogin = async () => {
        // Clear previous errors
        errors.phone = null;
        errors.general = null;
        try {
            // Send E.164: prefix '+' and send only digits (this matches the httpie command that worked)
            const numericPhone = credentials.phone ? String(credentials.phone).replace(/\D/g, '') : '';
            if (!numericPhone) {
                errors.phone = 'Informe um número de telefone válido';
                return;
            }

            const e164 = '+' + numericPhone;
            const payload = { phone: e164 };

            // Debug: store the payload we are about to send
            payloadSent.value = payload;

            const response = await axios.post('/api/login', payload);
            console.log(response.data);
            serverResponse.value = response.data;
            // handle success (redirect, store token, etc.)
            waitingOnVerification.value = true;
        } catch (error) {
            if (error.response) {
                const data = error.response.data;
                serverResponse.value = data;
                // Laravel validation errors are usually in data.errors
                if (data.errors && data.errors.phone) {
                    errors.phone = Array.isArray(data.errors.phone) ? data.errors.phone.join(' ') : data.errors.phone;
                }
                // Generic message
                errors.general = data.message || null;
                console.error('Login error (response):', data);
            } else {
                serverResponse.value = { message: error.message };
                console.error('Login request failed (no response):', error.message, error);
                errors.general = 'Network error: ' + (error.message || 'Request failed');
            }
        }
    }


    const handleVerification = async () => {
        // Send phone in E.164 (same format we used when requesting the code)
        const numericOnly = credentials.phone ? String(credentials.phone).replace(/\D/g, '') : '';
        const e164 = numericOnly ? ('+' + numericOnly) : '';
        if (!e164) {
            errors.general = 'Telefone inválido para verificação';
            return;
        }

        try {
            const response = await axios.post('/api/verify', {
                phone: e164,
                login_code: credentials.login_code
            });
            console.log('Verification successful:', response.data); // auth token or whatever backend returns
            serverResponse.value = response.data;
            // handle success (redirect, store token, etc.)
            localStorage.setItem('token', response.data);
            router.push({       // Redireciona para a pagina "landing"
                name: 'landing'
            })


        } catch (error) {
            console.error('Verification error:', error);
            if (error.response) {
                serverResponse.value = error.response.data;
                errors.general = error.response.data?.message || 'Verification failed';
            } else {
                errors.general = 'Network error during verification';
            }
        }
    }


</script>



<style>

</style>