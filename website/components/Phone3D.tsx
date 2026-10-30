import React, { useRef, useState, useEffect } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, PerspectiveCamera, RoundedBox } from '@react-three/drei';
import * as THREE from 'three';

interface Phone3DProps {
  screenshots: string[];
}

function PhoneModel({ texture }: { texture: THREE.Texture | null }) {
  const meshRef = useRef<THREE.Group>(null);

  // Gentle auto-rotation
  useFrame((state) => {
    if (meshRef.current) {
      meshRef.current.rotation.y = Math.sin(state.clock.elapsedTime * 0.3) * 0.08;
    }
  });

  if (!texture) return null;

  return (
    <group ref={meshRef}>
      {/* Phone Body (Rounded Frame) */}
      <RoundedBox args={[2.0, 4.2, 0.12]} radius={0.2} smoothness={4} position={[0, 0, -0.06]}>
        <meshStandardMaterial color="#1E1E24" metalness={0.8} roughness={0.2} />
      </RoundedBox>

      {/* Phone Screen */}
      <mesh position={[0, 0, 0.01]}>
        <planeGeometry args={[1.8, 3.8]} />
        <meshStandardMaterial map={texture} />
      </mesh>

      {/* Screen Border Glow */}
      <mesh position={[0, 0, 0.02]}>
        <planeGeometry args={[1.85, 3.85]} />
        <meshBasicMaterial color="#FFAB91" transparent opacity={0.08} />
      </mesh>

      {/* Camera Notch */}
      <mesh position={[0, 1.85, 0.07]}>
        <cylinderGeometry args={[0.06, 0.06, 0.02, 32]} />
        <meshStandardMaterial color="#0F1014" />
      </mesh>
    </group>
  );
}

export const Phone3D: React.FC<Phone3DProps> = ({ screenshots }) => {
  const [textures, setTextures] = useState<THREE.Texture[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  // Preload ALL screenshots once on mount
  useEffect(() => {
    console.log('🚀 Starting texture preloading...');
    const loader = new THREE.TextureLoader();

    const loadPromises = screenshots.map(
      (path) => new Promise<THREE.Texture>((resolve, reject) => {
        loader.load(
          path,
          (texture) => {
            console.log('✅ Preloaded:', path);
            resolve(texture);
          },
          undefined,
          (error) => {
            console.error('❌ Failed to preload:', path, error);
            reject(error);
          }
        );
      })
    );

    Promise.all(loadPromises)
      .then((loadedTextures) => {
        setTextures(loadedTextures);
        setIsLoading(false);
        console.log('🎉 All screenshots preloaded! Total:', loadedTextures.length);
      })
      .catch((error) => {
        console.error('❌ Preloading failed:', error);
        setIsLoading(false);
      });

    // Cleanup: Dispose textures on unmount
    return () => {
      textures.forEach(texture => texture.dispose());
    };
  }, [screenshots]);

  // Auto-rotate through preloaded textures every 4 seconds
  useEffect(() => {
    if (textures.length === 0) return;

    const interval = setInterval(() => {
      setCurrentIndex((prev) => {
        const next = (prev + 1) % textures.length;
        console.log(`🔄 Switching to screenshot ${next + 1}/${textures.length}`);
        return next;
      });
    }, 4000);

    return () => clearInterval(interval);
  }, [textures.length]);

  if (isLoading) {
    return (
      <div className="w-full h-[500px] flex items-center justify-center bg-[#1E1E24] rounded-3xl">
        <div className="text-white/50">3D-Phone wird geladen...</div>
      </div>
    );
  }

  if (textures.length === 0) {
    return (
      <div className="w-full h-[500px] flex items-center justify-center bg-[#1E1E24] rounded-3xl">
        <div className="text-red-400">Fehler beim Laden der Screenshots</div>
      </div>
    );
  }

  return (
    <div className="w-full h-[500px] relative">
      <Canvas>
        <PerspectiveCamera makeDefault position={[0, 0, 5]} />

        {/* Lighting */}
        <ambientLight intensity={0.5} />
        <directionalLight position={[10, 10, 5]} intensity={1} />
        <pointLight position={[-10, -10, -5]} intensity={0.5} color="#FFAB91" />

        {/* 3D Phone Model with preloaded texture */}
        <PhoneModel texture={textures[currentIndex]} />

        {/* Interactive Controls - Limited Rotation */}
        <OrbitControls
          enableZoom={true}
          enablePan={false}
          minDistance={3}
          maxDistance={8}
          minAzimuthAngle={-Math.PI / 3}
          maxAzimuthAngle={Math.PI / 3}
          maxPolarAngle={Math.PI / 1.8}
          minPolarAngle={Math.PI / 3}
          autoRotate={false}
        />
      </Canvas>
    </div>
  );
};
