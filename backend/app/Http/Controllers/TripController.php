<?php

namespace App\Http\Controllers;

use App\Events\TripAccepted;
use App\Events\TripStarted;
use App\Events\TripEnded;
use App\Events\TripLocationUpdated;
use Illuminate\Http\Request;
use App\Models\Trip;

class TripController extends Controller
{
    //

    public function store(Request $request)
    {
        $request->validate([
            'origin' => 'required',
            'destination' => 'required',
            'destination_name' => 'required'
        ]);

        return $request->user()->trips()->create($request->only([
            'origin',
            'destination',
            'destination_name'
        ]));
    }


    public function show(Request $request, Trip $trip)
    {
        // is the trip is assocaited with the authenticated user?

        if ($trip->user->id === $request->user()->id){
            return $trip;
        }

        if ($trip->driver && $request->user()->driver){
            if ($trip->driver->id === $request->user()->driver->id){
                return $trip;
            }
        }


        return response()->json(['message' => 'This trip is not associated with the authenticated user.'], 404);
    }


    public function accept(Request $request, Trip $trip)
    {
        //driver accppts a trip

        $request->validate([
            'driver_location' => 'required'
        ]);

        $trip->update([
            'driver_id' => $request->user()->id,
            'driver_location' => $request->driver_location,
            'status' => 'accepted',
        ]);

        $trip->load('driver.user');

        TripAccepted::dispatch($trip, $request->user());

        return $trip;
    }


    public function start(Request $request, Trip $trip)
    {
        //driver has started taking the passenger to the destination

        $trip->update([
            'is_started' => true
        ]);

        $trip->load('driver.user');

        TripStarted::dispatch($trip, $request->user());

        return $trip;

    }


    public function end(Request $request, Trip $trip)
    {
        //a drvier has ended a trip

        $trip->update([
            'is_complete' => true,
        ]);

        $trip->load('driver.user');

        TripEnded::dispatch($trip, $request->user());
        return $trip;

    }


    public function location(Request $request, Trip $trip)
    {
        // update the drivers current location

        $request->validate([
            'driver_location' => 'required'
        ]);

        $trip->update([
            'driver_location' => $request->driver_location
        ]);

        $trip->load('driver.user');

        TripLocationUpdated::dispatch($trip, $request->user());

        return $trip;

    }







}
