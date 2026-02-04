<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Party;
use Illuminate\Http\Request;

class PartyController extends Controller
{
    /**
     * Get all parties for a company
     */
    public function index(Request $request)
    {
        $request->validate([
            'company_id' => 'required|integer',
        ]);

        // Verify access
        $hasAccess = $request->user()->companies()
            ->where('companies.id', $request->company_id)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'success' => false,
                'message' => 'You do not have access to this company',
            ], 403);
        }

        $parties = Party::where('company_id', $request->company_id)
            ->where('is_active', true)
            ->get();

        return response()->json([
            'success' => true,
            'parties' => $parties,
        ]);
    }

    /**
     * Create a new party
     */
    public function store(Request $request)
    {
        $request->validate([
            'company_id' => 'required|integer',
            'name' => 'required|string|max:255',
            'party_type' => 'required|in:customer,supplier,both',
            'customer_class' => 'nullable|in:retailer,wholesaler,other',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|email',
            'address' => 'nullable|string',
            'opening_balance' => 'nullable|numeric',
            'credit_limit' => 'nullable|numeric',
            'payment_terms_days' => 'nullable|integer',
        ]);

        $party = Party::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Party created successfully',
            'party' => $party,
        ], 201);
    }

    /**
     * Update a party
     */
    public function update(Request $request, $id)
    {
        $party = Party::findOrFail($id);

        // Verify access
        $hasAccess = $request->user()->companies()
            ->where('companies.id', $party->company_id)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'success' => false,
                'message' => 'You do not have access to this company',
            ], 403);
        }

        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'party_type' => 'sometimes|required|in:customer,supplier,both',
            'customer_class' => 'nullable|in:retailer,wholesaler,other',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|email',
            'address' => 'nullable|string',
            'opening_balance' => 'nullable|numeric',
            'credit_limit' => 'nullable|numeric',
            'payment_terms_days' => 'nullable|integer',
        ]);

        $party->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Party updated successfully',
            'party' => $party,
        ]);
    }

    /**
     * Delete a party
     */
    public function destroy(Request $request, $id)
    {
        $party = Party::findOrFail($id);

        // Verify access
        $hasAccess = $request->user()->companies()
            ->where('companies.id', $party->company_id)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'success' => false,
                'message' => 'You do not have access to this company',
            ], 403);
        }

        $party->delete();

        return response()->json([
            'success' => true,
            'message' => 'Party deleted successfully',
        ]);
    }
}
