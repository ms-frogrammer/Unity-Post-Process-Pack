using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CRTPostProcess : MonoBehaviour
{
    public CRTProcessProfile profile;
    CRTProcessProfile p;

    private Material material;

    // Use this for initialization
    void Start()
    {
        p = profile;
        material = new Material(p.shader);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetFloat("u_time", Time.fixedTime);

        material.SetFloat("u_hue", p.hue_shift);
        material.SetFloat("u_saturation", p.saturation);
        material.SetFloat("u_colors_intensity", p.intensity);

        material.SetFloat("u_zoom", p.zoom);

        material.SetFloat("u_bend", p.bend);
        material.SetFloat("u_middle_bend", p.middle_bend);

        material.SetFloat("u_scanline_size_1", p.scanlineSize1);
        material.SetFloat("u_scanline_speed_1", p.scanlineSpeed1);
        material.SetFloat("u_scanline_size_2", p.scanlineSize2);
        material.SetFloat("u_scanline_speed_2", p.scanlineSpeed2);
        material.SetFloat("u_scanline_amount", p.scanlineAmount);

        material.SetFloat("u_vignette_size", p.vignetteSize);
        material.SetFloat("u_vignette_smoothness", p.vignetteSmoothness);
        material.SetFloat("u_vignette_edge_round", p.vignetteEdgeRound);

        material.SetFloat("u_noise_size", p.noiseSize);
        material.SetFloat("u_noise_amount", p.noiseAmount);

        material.SetFloat("u_chromo_intensity", p.chromoIntensity);
        material.SetVector("u_red_offset", p.redOffset);
        material.SetVector("u_blue_offset", p.blueOffset);
        material.SetVector("u_green_offset", p.greenOffset);
        Graphics.Blit(source, destination, material);
    }
}