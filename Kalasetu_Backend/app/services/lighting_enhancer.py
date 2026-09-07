import torch
import torch.nn as nn
import numpy as np
import cv2
import os


class ZeroDCE(nn.Module):
    def __init__(self):
        super().__init__()
        number_f = 32
        self.relu = nn.ReLU(inplace=True)
        self.e_conv1 = nn.Conv2d(3, number_f, 3, 1, 1)
        self.e_conv2 = nn.Conv2d(number_f, number_f, 3, 1, 1)
        self.e_conv3 = nn.Conv2d(number_f, number_f, 3, 1, 1)
        self.e_conv4 = nn.Conv2d(number_f, number_f, 3, 1, 1)
        self.e_conv5 = nn.Conv2d(number_f * 2, number_f, 3, 1, 1)
        self.e_conv6 = nn.Conv2d(number_f * 2, number_f, 3, 1, 1)
        self.e_conv7 = nn.Conv2d(number_f * 2, 24, 3, 1, 1)

    def forward(self, x):
        x1 = self.relu(self.e_conv1(x))
        x2 = self.relu(self.e_conv2(x1))
        x3 = self.relu(self.e_conv3(x2))
        x4 = self.relu(self.e_conv4(x3))
        x5 = self.relu(self.e_conv5(torch.cat([x3, x4], 1)))
        x6 = self.relu(self.e_conv6(torch.cat([x2, x5], 1)))
        x_r = torch.tanh(self.e_conv7(torch.cat([x1, x6], 1)))
        r1, r2, r3, r4, r5, r6, r7, r8 = torch.split(x_r, 3, dim=1)

        x = x + r1 * (torch.pow(x, 2) - x)
        x = x + r2 * (torch.pow(x, 2) - x)
        x = x + r3 * (torch.pow(x, 2) - x)
        enhanced = x + r4 * (torch.pow(x, 2) - x)
        x = enhanced + r5 * (torch.pow(enhanced, 2) - enhanced)
        x = x + r6 * (torch.pow(x, 2) - x)
        x = x + r7 * (torch.pow(x, 2) - x)
        enhanced = x + r8 * (torch.pow(x, 2) - x)
        return enhanced


_model = None
MODEL_DIR = os.path.join(os.path.dirname(__file__), "..", "models")
DEFAULT_WEIGHTS_PATH = os.path.join(MODEL_DIR, "zero_dce.pth")


def load_zero_dce(weights_path: str = DEFAULT_WEIGHTS_PATH):
    global _model
    if _model is None:
        _model = ZeroDCE()
        _model.load_state_dict(torch.load(weights_path, map_location="cpu"))
        _model.eval()
    return _model


def enhance_lighting_zero_dce(image_bgr: np.ndarray) -> np.ndarray:
    model = load_zero_dce()
    img_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0
    tensor = torch.from_numpy(img_rgb).permute(2, 0, 1).unsqueeze(0)

    with torch.no_grad():
        enhanced = model(tensor)

    enhanced = enhanced.squeeze(0).permute(1, 2, 0).clamp(0, 1).numpy()
    enhanced_bgr = cv2.cvtColor((enhanced * 255).astype(np.uint8), cv2.COLOR_RGB2BGR)
    return enhanced_bgr