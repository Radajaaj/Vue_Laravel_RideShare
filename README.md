# Vue_Laravel_RideShare
Simple ride share app implemented using PHP and JavaScript with the Laravel and Vue.js frameworks.

After loggin in, an user is presented with two options: Being an driver or a passenger.

The passengers will define the starting point and the destiny, and the drivers will receive a notification every time a new passenger asks for a new run. The first driver to accept the notification is assigned to the run.
After that, the run starts appening. The passenger can cancel it, and the driver can mark it as completed.

How to use (backend and API's):
    Run "sudo php artisan serve --port=80" on the backend folder
    Use the login route: "http POST localhost/api/login phone=+YourPhoneHere"
        it should send an verification code to your phone.
    http POST localhost/api/login/verify phone=+YourPhoneHere login_code=YourCodeHere
        This will return the authentication code. Use it from now on.
    Get user data:      http GET localhost/api/user 'Authorization: Bearer 1|JeK5DcTLy2m8wWfdemkCp4X5p7ckggqTKPvtrfeP2e2ee88d'
    Get driver data:    http GET localhost/api/driver 'Authorization: Bearer 1|JeK5DcTLy2m8wWfdemkCp4X5p7ckggqTKPvtrfeP2e2ee88d'
    Update driver data: http POST localhost/api/driver 'Authorization: Bearer 2|es8VOg4qA5E0y90ccjy7JhfTgcl6zy43B00zjfnS32873362' Accept:application/json name='Ronaldo Silva' car_year:=2019 car_brand='Toyota' car_model='Corolla' car_color='White' car_license_plate='ABC-1234'

    You can create a trip (from an regular User perspective): http POST localhost/api/trip 'Authorization: Bearer 2|es8VOg4qA5E0y90ccjy7JhfTgcl6zy43B00zjfnS32873362' destination_name=Starbucks destination:='{"lat": 12.12312, "lng": 23.12312321}' origin:='{"lat": 2.12312, "lng": 28.12312321}'
    It will return an json containing the trip ID.
    You can use that ID to get data from this trip: http GET localhost/api/trip/1 'Authorization: Bearer 2|es8VOg4qA5E0y90ccjy7JhfTgcl6zy43B00zjfnS32873362'

Setting up Reverb Websockets:
    Run "php artisan reverb:start" or "php artisan reverb:start --host=127.0.0.1 --port=8080" (you can chose the host and port)