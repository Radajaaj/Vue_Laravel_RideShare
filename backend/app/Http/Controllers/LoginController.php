<?php

namespace App\Http\Controllers;

use App\Notifications\LoginNeedsVerification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    public function submit(Request $request)
    {
        // validate the phone number (to see if the thing really is a phone number)
        $request->validate([             // Validate the "phone" field in the request json thingie
            'phone' => 'required|numeric|min:10'
        ]);

        // find or create a user model associated with it
        $user = User::firstOrCreate([           // Search if a user exists with this phone, if not, creates one.
            'phone' => $request->phone,         // key to search/create
        ]);

        if (!$user){
            return response()->json(['message' => 'Could not process a user with that phone number.'], 401);
        }



        // send the user a one time use code
        $user->notify(new LoginNeedsVerification());


        // return back a response / success message
        return response()->json(['message'=> 'Text Message Notification Sent.'], 200);
    }


    public function verify(Request $request)
    {

        // vaidate the incoming request
        $request->validate([
            'phone'         => 'required|numeric|min:10',
            'login_code'    => 'required|numeric|between:100000,999999',
        ]);

        // find the user
        $user = User::where('phone', $request->phone)
                ->where('login_code', $request->login_code)
                ->first();

        // is the code provided the same one saved?

        // if so, return an auth token
        if ($user) {
            $user->update(['login_code' => null]); // invalidate the code after successful login
            return $user->createToken($request->login_code)->plainTextToken;
        }

        //if not, return error message
        return response()->json(['message' => 'The provided login code is incorrect.'], 401);

    }

}
