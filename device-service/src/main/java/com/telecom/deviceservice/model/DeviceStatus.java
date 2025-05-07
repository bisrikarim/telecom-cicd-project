package com.telecom.deviceservice.model;

public enum DeviceStatus {
    ONLINE,     // Équipement en ligne et fonctionnel
    OFFLINE,    // Équipement hors ligne
    WARNING,    // Équipement en ligne mais avec des alertes
    DEGRADED,   // Équipement fonctionnel mais avec des performances dégradées
    MAINTENANCE,// Équipement en maintenance planifiée
    FAILED      // Équipement en panne
}