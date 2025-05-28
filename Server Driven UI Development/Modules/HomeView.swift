//
//  HomeView.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 13/11/24.
//

import SwiftUI

struct HomeView: View {
    let config: HomeConfig
    @StateObject var viewModel: AppConfigViewModel
    @State private var selectedTrackId: String
    
    init(config: HomeConfig, viewModel: AppConfigViewModel) {
        self.config = config
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._selectedTrackId = State(initialValue: config.tracksConfig.selectedTrackId ?? config.tracksConfig.tracks.first?.id ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Image
                if let imageURL = config.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                // Track Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(config.tracksConfig.tracks) { track in
                            TrackTabButton(
                                track: track,
                                isSelected: selectedTrackId == track.id,
                                action: { selectedTrackId = track.id }
                            )
                        }
                    }
                    .padding()
                }
                
                // Talks List
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredTalks) { talk in
                            TalkCard(talk: talk)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: signOutButton)
            .background(Color(hex: config.backgroundColor ?? "#FFFFFF"))
        }
    }
    
    private var filteredTalks: [Talk] {
        config.tracksConfig.tracks
            .first(where: { $0.id == selectedTrackId })?
            .talks ?? []
    }
    
    private var signOutButton: some View {
        Button {
            Task {
                viewModel.signOut()
            }
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
        }
    }
}

struct TrackTabButton: View {
    let track: Track
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(track.name)
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    isSelected ?
                    Color(hex: track.color ?? "#000000") :
                    Color(hex: track.color ?? "#000000").opacity(0.1)
                )
                .foregroundColor(isSelected ? .white : Color(hex: track.color ?? "#000000"))
                .cornerRadius(20)
        }
    }
}

struct TalkCard: View {
    let talk: Talk
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageURL = talk.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(height: 150)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(talk.title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(talk.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(talk.speakerName)
                            .font(.headline)
                        if let role = talk.speakerRole {
                            Text(role)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(talk.time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let location = talk.location {
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let tags = talk.tags {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}
