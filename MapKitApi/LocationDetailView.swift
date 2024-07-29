//
//  LocationDetailView.swift
//  MapKitApi
//
//  Created by 羅子淵 on 2024/7/26.
//

import SwiftUI
import MapKit
struct LocationDetailView: View {
    @Binding var mapSelection: MKMapItem?
    @Binding var show:Bool
    @Binding var getDirection:Bool
    @State private var lookAroundScene:MKLookAroundScene?
    var body: some View {
        
        VStack {
            HStack{
                VStack(alignment: .leading){
                    Text(mapSelection?.placemark.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                Spacer()
                Button{
                    show.toggle()
                    mapSelection = nil
                }label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24,height: 24)
                        .foregroundStyle(.gray, Color(.systemGray6))
                }
            }
        }
        HStack(spacing:24){
            Button{
                if let mapSelection{
                    mapSelection.openInMaps()
                }
            }label: {
                Text("Open In Maps")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 170, height: 48)
                    .background(.green)
                    .cornerRadius(12)
            }
            Button{
                getDirection = true
                show = false
                
            }label: {
                Text("get directions")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 170,height: 40)
                    .background(.blue)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    
        .onAppear{
            print("DEBUG: Did call on appear")
            fetchLookAroundPreview()
        }
        .onChange(of: mapSelection) {
            oldValue, newValue in
            print("DEBUG: DID call on Change")
                fetchLookAroundPreview()
        }
        
        if let scene = lookAroundScene{
            LookAroundPreview(initialScene: scene)

            .frame(height: 200)
            .cornerRadius(12)
            .padding()
        }else{
            ContentUnavailableView("No preview avaliable", systemImage: "eye.slash")
        }
    }
}
extension LocationDetailView{
    func fetchLookAroundPreview(){
        if let mapSelection{
            lookAroundScene = nil
            Task{
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}

#Preview {
    LocationDetailView(mapSelection: .constant(nil), show: .constant(false), getDirection: .constant(false))
}
