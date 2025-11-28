package com.loapalette.android

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.loapalette.shared.createApplicationScreenMessage

@Composable
fun App() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF007AFF),
                        Color(0xFF5856D6)
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        GlassEffectCard()
    }
}

@Composable
fun GlassEffectCard() {
    Box(
        modifier = Modifier
            .width(300.dp)
            .height(200.dp)
            .background(
                color = Color.White.copy(alpha = 0.3f),
                shape = androidx.compose.foundation.shape.RoundedCornerShape(20.dp)
            )
            .padding(24.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "LoaPalette",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = createApplicationScreenMessage(),
                fontSize = 16.sp,
                color = Color.White.copy(alpha = 0.9f)
            )
        }
    }
}

