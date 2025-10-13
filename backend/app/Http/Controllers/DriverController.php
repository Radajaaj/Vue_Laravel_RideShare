<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class DriverController extends Controller
{
    //

    public function show(Request $request)
    {
        //return back the user and associated driver model
        $user = $request->user();
        $user->load('driver');

        return $user;
    }

    public function update(Request $request)
    {
        $request->validate([
            'car_year'          => 'required|numeric|between:2010,2026',
            'car_brand'         => 'required|string|max:255',
            'car_model'         => 'required|string|max:255',
            'car_color'         => 'required|alpha',
            'car_license_plate' => 'required|string|max:255',
            'name'              => 'required|string|max:255',
        ]);

        $user = $request->user();

        $user->update($request->only('name'));

        // create or update a driver associated with this user
        $user->driver()->updateOrCreate($request->only([
            'car_year',
            'car_brand',
            'car_model',
            'car_color',
            'car_license_plate',
        ]));

        $user->load('driver');

        return $user;

    }
}
