package com.personal.voiceon

import android.content.Context
import android.net.Uri
import android.provider.ContactsContract

object ContactResolver {
    fun getContactName(context: Context, phoneNumber: String): String {
        if (phoneNumber.isBlank()) return ""
        val uri = Uri.withAppendedPath(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
            Uri.encode(phoneNumber)
        )
        val cursor = context.contentResolver.query(
            uri,
            arrayOf(ContactsContract.PhoneLookup.DISPLAY_NAME),
            null, null, null
        )
        return cursor?.use {
            if (it.moveToFirst()) it.getString(0) else ""
        } ?: ""
    }
}
