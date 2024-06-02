package com.example.tutorial

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.app.ActivityOptions
import android.content.Intent
import android.os.Build
import android.transition.Slide
import android.transition.Transition
import android.transition.TransitionManager
import android.view.Gravity
import android.view.Window

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val slide = Slide()
            slide.slideEdge = Gravity.BOTTOM
            window.enterTransition = slide
        }
    }

    // コンテンツを表示する場合は、下から出す
    override fun startActivityForResult(intent: Intent, requestCode: Int, options: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && intent.hasCategory("android.intent.category.DEFAULT")) {
            val slide = Slide()
            slide.slideEdge = Gravity.BOTTOM
            window.exitTransition = slide
            val bundle = ActivityOptions.makeSceneTransitionAnimation(this).toBundle()
            super.startActivityForResult(intent, requestCode, bundle)
        } else {
            super.startActivityForResult(intent, requestCode, options)
        }
    }
}