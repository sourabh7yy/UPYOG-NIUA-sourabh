import React, { useState,useEffect, useRef } from "react";
import { Modal, Toast } from "@upyog/digit-ui-react-components";
import { MapContainer, TileLayer, FeatureGroup } from "react-leaflet";
import { EditControl } from "react-leaflet-draw";
import * as turf from "@turf/turf";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import "leaflet-draw/dist/leaflet.draw.css";

/**
 * @author - Shivank - NUDM
 * 
 * Interactive map component for property boundary marking in UPYOG asset management system.
 * Developed to enable field officers to digitally mark immovable asset boundaries by drawing 
 * shapes (polygons, rectangles, markers) on OpenStreetMap and automatically calculate area in square meters.
 * 
 * Usage: Pass location coordinates, onGeometrySave callback for GeoJSON data, and onAreaSave callback 
 * for calculated area. Component renders in modal with drawing tools on map's top-right corner.
 */


const Close = () => (
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#FFFFFF">
        <path d="M0 0h24v24H0V0z" fill="none" />
        <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12 19 6.41z" />
    </svg>
);

const CloseBtn = (props) => {
    return (
        <div className="icon-bg-secondary" onClick={props.onClick}>
            <Close />
        </div>
    );
};



const MarkOnMap = ({closeModal,location,onGeometrySave,onAreaSave,savedGeometry, savedArea}) => {
  const [geometry, setGeometry] = useState(savedGeometry || null);
  const [area, setArea] = useState(savedArea || null);
  const [showToast, setShowToast] = useState(null);
  const [map, setMap] = useState(null);
  const featureGroupRef = useRef(null);
  const center = location 
    ? [location.lat, location.lng]
    : [20.5937, 78.9629]; // default India center



    // Load saved geometry AFTER both map + featureGroup are ready
  useEffect(() => {
        if (!map || !featureGroupRef.current || !savedGeometry) return;

        featureGroupRef.current.clearLayers();
        try {
        const geoJsonLayer = L.geoJSON(savedGeometry);
        geoJsonLayer.eachLayer((layer) => {
            featureGroupRef.current.addLayer(layer);
            map.fitBounds(layer.getBounds());
        });

        if (savedGeometry.geometry?.type === "Polygon") {
            const polygon = turf.polygon(savedGeometry.geometry.coordinates);
            setArea(turf.area(polygon));
        }
        } catch (err) {
        console.error("Error restoring geometry:", err);
        }
  }, [map, savedGeometry]);

  const _onCreated = (e) => {
    const { layer } = e;
    const geoJson = layer.toGeoJSON();
    setGeometry(geoJson);

     // Pass to parent if needed
    if (onGeometrySave) {
      onGeometrySave(geoJson);
    }

    // ✅ If polygon, calculate area
    if (geoJson.geometry.type === "Polygon") {
      const polygon = turf.polygon(geoJson.geometry.coordinates);
      const polygonArea = turf.area(polygon); // returns area in square meters
      setArea(polygonArea);
      onAreaSave ? onAreaSave(polygonArea):null
      
    }
  };

  const _onEdited = (e) => {
    const layers = e.layers;
    layers.eachLayer((layer) => {
      const geoJson = layer.toGeoJSON();
      setGeometry(geoJson);
      
      if (onGeometrySave) {
        onGeometrySave(geoJson);
      }

      // Recalculate area after editing
      if (geoJson.geometry.type === "Polygon") {
        const polygon = turf.polygon(geoJson.geometry.coordinates);
        const polygonArea = turf.area(polygon);
        setArea(polygonArea);
        onAreaSave ? onAreaSave(polygonArea) : null;
      }
    });
  };

  const _onDeleted = (e) => {
    setGeometry(null);
    setArea(null);
    if (onGeometrySave) {
      onGeometrySave(null);
    }
    if (onAreaSave) {
      onAreaSave(null);
    }
  };


  useEffect(() => {
        if (geometry && area) {
          setShowToast({ error: false, label: ("Marking Successfully Captured") });
        }
      }, [geometry, area]);

  useEffect(() => {
      if (showToast) {
        const timer = setTimeout(() => setShowToast(null), 2000);
        return () => clearTimeout(timer);
      }
    }, [showToast]);

  return (
     <Modal
        headerBarEnd={<CloseBtn onClick={closeModal} />}
        hideSubmit={true}
        formId="modal-action"
        popupStyles={{ width: "90vw", height: "85vh" }}
        >
        <div style={{ height: "700px" }}>
          <MapContainer
            center={center}
            zoom={20}
            style={{ height: "100%", width: "100%" }}
            whenCreated={setMap}
          >
            <TileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              attribution="&copy; OpenStreetMap contributors"
            />

            <FeatureGroup ref={featureGroupRef}>
              <EditControl
                position="topright"
                onCreated={_onCreated}
                onEdited={_onEdited}
                onDeleted={_onDeleted}
                draw={{
                  rectangle: true,
                  polygon: true,
                  polyline: true,
                  circle: false,
                  marker: true,
                  circlemarker: false,
                }}
                edit={{
                edit: true,
                remove: true,
              }}
              />
            </FeatureGroup>
          </MapContainer>
        </div>
        {showToast && (
              <Toast
                error={showToast.error}
                warning={showToast.warning}
                label={(showToast.label)}
                onClose={() => setShowToast(null)}
              />
            )}
    </Modal>
  );
};

export default MarkOnMap;
