package com.telecom.deviceservice.repository;

import com.telecom.deviceservice.model.Device;
import com.telecom.deviceservice.model.DeviceStatus;
import com.telecom.deviceservice.model.DeviceType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface DeviceRepository extends JpaRepository<Device, Long> {

    Optional<Device> findBySerialNumber(String serialNumber);
    
    List<Device> findByType(DeviceType type);
    
    List<Device> findByStatus(DeviceStatus status);
    
    List<Device> findByManufacturer(String manufacturer);
    
    List<Device> findByLocation(String location);
    
    @Query("SELECT d FROM Device d WHERE d.status = com.telecom.deviceservice.model.DeviceStatus.WARNING OR d.status = com.telecom.deviceservice.model.DeviceStatus.DEGRADED")
    List<Device> findDevicesNeedingMaintenance();
    
    @Query("SELECT COUNT(d) FROM Device d GROUP BY d.status")
    List<Object[]> countByStatus();
}