
<template>
    <div class="pt-16">
        <h1 class="text-3xl font-semibold mb-4"> Urbe</h1>
        <div class="overflow-hidden shadow sm:rounded-md max-w-sm mx-auto text-left">
            <div class="bg-white px-4 py-5 sm:p-6">
                <div class="flex justify-between">
                    <button 
                        class="rounded-md border border-transparent bg-blue-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                        Sou Motorista
                    </button>
                    <button 
                    @click="handleFindARide"
                        class="rounded-md border border-transparent bg-green-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2">
                        Sou Passageiro
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>



<script setup>
    const router = useRouter()
    const handleFindARide = () => {
        router.push({
            name: 'location'
        })
    }

</script>